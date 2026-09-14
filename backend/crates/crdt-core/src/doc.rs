use yrs::{
    updates::decoder::Decode,
    updates::encoder::Encode,
    Doc, ReadTxn, StateVector, Transact, Update,
};
use thiserror::Error;

#[derive(Error, Debug)]
pub enum CrdtError {
    #[error("Failed to decode update binary: {0}")]
    DecodeError(String),
    #[error("Internal CRDT error: {0}")]
    Internal(String),
}

/// A wrapper around a `yrs::Doc` for managing a trip's offline-first CRDT state.
pub struct TripCrdtDoc {
    doc: Doc,
}

impl Default for TripCrdtDoc {
    fn default() -> Self {
        Self::new()
    }
}

impl TripCrdtDoc {
    pub fn new() -> Self {
        Self { doc: Doc::new() }
    }

    /// Creates a doc by replaying an existing binary update / snapshot.
    pub fn from_snapshot(snapshot: &[u8]) -> Result<Self, CrdtError> {
        let doc = Doc::new();
        if !snapshot.is_empty() {
            let update = Update::decode_v1(snapshot)
                .map_err(|e| CrdtError::DecodeError(e.to_string()))?;
            let mut txn = doc.transact_mut();
            let _ = txn.apply_update(update);
        }
        Ok(Self { doc })
    }

    /// Computes the current StateVector of this document.
    pub fn state_vector(&self) -> Vec<u8> {
        let txn = self.doc.transact();
        txn.state_vector().encode_v1()
    }

    /// Encodes the entire document state into a single v1 snapshot.
    pub fn encode_snapshot(&self) -> Vec<u8> {
        let txn = self.doc.transact();
        txn.encode_state_as_update_v1(&StateVector::default())
    }

    /// Computes missing updates for a remote peer given their StateVector.
    pub fn diff_since_state_vector(&self, remote_sv_bytes: &[u8]) -> Result<Vec<u8>, CrdtError> {
        let remote_sv = StateVector::decode_v1(remote_sv_bytes)
            .map_err(|e| CrdtError::DecodeError(e.to_string()))?;
        let txn = self.doc.transact();
        Ok(txn.encode_state_as_update_v1(&remote_sv))
    }

    /// Applies an incoming binary update into this document.
    pub fn apply_update(&self, update_bytes: &[u8]) -> Result<(), CrdtError> {
        let update = Update::decode_v1(update_bytes)
            .map_err(|e| CrdtError::DecodeError(e.to_string()))?;
        let mut txn = self.doc.transact_mut();
        let _ = txn.apply_update(update);
        Ok(())
    }

    /// Direct reference to inner Doc.
    pub fn inner(&self) -> &Doc {
        &self.doc
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use yrs::Map;

    #[test]
    fn test_crdt_sync_between_two_docs() {
        let doc_a = TripCrdtDoc::new();
        let doc_b = TripCrdtDoc::new();

        // Doc A writes a property
        {
            let map_a = doc_a.inner().get_or_insert_map("trip_meta");
            let mut txn = doc_a.inner().transact_mut();
            map_a.insert(&mut txn, "name", "Goa Vacation 2026");
        }

        // Get delta for Doc B
        let sv_b = doc_b.state_vector();
        let diff_for_b = doc_a.diff_since_state_vector(&sv_b).expect("diff failed");

        // Apply to Doc B
        doc_b.apply_update(&diff_for_b).expect("apply failed");

        // Verify Doc B has the updated data
        {
            let map_b = doc_b.inner().get_or_insert_map("trip_meta");
            let txn = doc_b.inner().transact();
            let val = map_b.get(&txn, "name").expect("key missing");
            assert_eq!(val.to_string(&txn), "Goa Vacation 2026");
        }
    }
}
