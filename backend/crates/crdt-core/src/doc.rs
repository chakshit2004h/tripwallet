use yrs::{
    updates::decoder::Decode,
    updates::encoder::Encode,
    Doc, Map, ReadTxn, StateVector, Transact, Update,
};
use serde::{Deserialize, Serialize};
use thiserror::Error;

#[derive(Error, Debug)]
pub enum CrdtError {
    #[error("Failed to decode update binary: {0}")]
    DecodeError(String),
    #[error("Internal CRDT error: {0}")]
    Internal(String),
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct MemberSummary {
    pub id: String,
    pub display_name: String,
    pub role: String,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct ExpenseSummary {
    pub id: String,
    pub title: String,
    pub amount_minor: i64,
    pub currency: String,
    pub paid_by: String,
    pub split_method: String,
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

    /// High-level mutation: adds a trip member and returns the resulting binary delta.
    pub fn add_member(&self, id: &str, display_name: &str, role: &str) -> Result<Vec<u8>, CrdtError> {
        let sv_before = self.state_vector();
        {
            let members_map = self.doc.get_or_insert_map("members");
            let mut txn = self.doc.transact_mut();
            let member_entry = members_map.insert(&mut txn, id, yrs::types::map::MapPrelim::default());
            member_entry.insert(&mut txn, "display_name", display_name);
            member_entry.insert(&mut txn, "role", role);
        }
        self.diff_since_state_vector(&sv_before)
    }

    /// High-level mutation: adds an expense and returns the resulting binary delta.
    pub fn add_expense(
        &self,
        id: &str,
        title: &str,
        amount_minor: i64,
        currency: &str,
        paid_by: &str,
        split_method: &str,
    ) -> Result<Vec<u8>, CrdtError> {
        let sv_before = self.state_vector();
        {
            let expenses_map = self.doc.get_or_insert_map("expenses");
            let mut txn = self.doc.transact_mut();
            let exp_entry = expenses_map.insert(&mut txn, id, yrs::types::map::MapPrelim::default());
            exp_entry.insert(&mut txn, "title", title);
            exp_entry.insert(&mut txn, "amount_minor", amount_minor);
            exp_entry.insert(&mut txn, "currency", currency);
            exp_entry.insert(&mut txn, "paid_by", paid_by);
            exp_entry.insert(&mut txn, "split_method", split_method);
        }
        self.diff_since_state_vector(&sv_before)
    }

    /// Extracts member summaries from the CRDT document for relational projections.
    pub fn get_members_summary(&self) -> Vec<MemberSummary> {
        let members_map = self.doc.get_or_insert_map("members");
        let txn = self.doc.transact();
        let mut summaries = Vec::new();

        for (id, val) in members_map.iter(&txn) {
            if let yrs::Out::YMap(m) = val {
                let name = m.get(&txn, "display_name")
                    .and_then(|v| match v { yrs::Out::Any(yrs::Any::String(s)) => Some(s.to_string()), _ => None })
                    .unwrap_or_default();
                let role = m.get(&txn, "role")
                    .and_then(|v| match v { yrs::Out::Any(yrs::Any::String(s)) => Some(s.to_string()), _ => None })
                    .unwrap_or_default();

                summaries.push(MemberSummary {
                    id: id.to_string(),
                    display_name: name,
                    role,
                });
            }
        }
        summaries
    }

    /// Extracts expense summaries from the CRDT document for relational projections.
    pub fn get_expenses_summary(&self) -> Vec<ExpenseSummary> {
        let expenses_map = self.doc.get_or_insert_map("expenses");
        let txn = self.doc.transact();
        let mut summaries = Vec::new();

        for (id, val) in expenses_map.iter(&txn) {
            if let yrs::Out::YMap(m) = val {
                let title = m.get(&txn, "title")
                    .and_then(|v| match v { yrs::Out::Any(yrs::Any::String(s)) => Some(s.to_string()), _ => None })
                    .unwrap_or_default();
                let amount = m.get(&txn, "amount_minor")
                    .and_then(|v| match v { 
                        yrs::Out::Any(yrs::Any::BigInt(b)) => Some(b),
                        yrs::Out::Any(yrs::Any::Number(n)) => Some(n as i64),
                        _ => None,
                    })
                    .unwrap_or(0);
                let currency = m.get(&txn, "currency")
                    .and_then(|v| match v { yrs::Out::Any(yrs::Any::String(s)) => Some(s.to_string()), _ => None })
                    .unwrap_or_default();
                let paid_by = m.get(&txn, "paid_by")
                    .and_then(|v| match v { yrs::Out::Any(yrs::Any::String(s)) => Some(s.to_string()), _ => None })
                    .unwrap_or_default();
                let split_method = m.get(&txn, "split_method")
                    .and_then(|v| match v { yrs::Out::Any(yrs::Any::String(s)) => Some(s.to_string()), _ => None })
                    .unwrap_or_default();

                summaries.push(ExpenseSummary {
                    id: id.to_string(),
                    title,
                    amount_minor: amount,
                    currency,
                    paid_by,
                    split_method,
                });
            }
        }
        summaries
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_crdt_sync_between_two_docs() {
        let doc_a = TripCrdtDoc::new();
        let doc_b = TripCrdtDoc::new();

        // Doc A writes member and expense
        let delta_member = doc_a.add_member("m1", "Rahul", "creator").unwrap();
        let delta_expense = doc_a.add_expense("e1", "Dinner", 3500, "INR", "m1", "equal").unwrap();

        // Doc B syncs updates
        doc_b.apply_update(&delta_member).unwrap();
        doc_b.apply_update(&delta_expense).unwrap();

        let members_b = doc_b.get_members_summary();
        let expenses_b = doc_b.get_expenses_summary();

        assert_eq!(members_b.len(), 1);
        assert_eq!(members_b[0].display_name, "Rahul");
        assert_eq!(expenses_b.len(), 1);
        assert_eq!(expenses_b[0].amount_minor, 3500);
    }

    use proptest::prelude::*;

    proptest! {
        #[test]
        fn test_crdt_commutativity_proptest(
            title1 in "[A-Za-z0-9]{3,10}",
            amount1 in 100i64..50_000,
            title2 in "[A-Za-z0-9]{3,10}",
            amount2 in 100i64..50_000,
        ) {
            let doc_server = TripCrdtDoc::new();
            let doc_client_a = TripCrdtDoc::new();
            let doc_client_b = TripCrdtDoc::new();

            // Client A creates an expense offline
            let delta_a = doc_client_a.add_expense("exp-a", &title1, amount1, "INR", "m1", "equal").unwrap();

            // Client B creates a different expense offline
            let delta_b = doc_client_b.add_expense("exp-b", &title2, amount2, "INR", "m2", "equal").unwrap();

            // Server receives in Order 1: A then B
            doc_server.apply_update(&delta_a).unwrap();
            doc_server.apply_update(&delta_b).unwrap();

            // An alternate node receives in reversed Order 2: B then A
            let doc_alt = TripCrdtDoc::new();
            doc_alt.apply_update(&delta_b).unwrap();
            doc_alt.apply_update(&delta_a).unwrap();

            // Assert semantic convergence: both docs have identical data and zero delta diff
            let mut exps_server = doc_server.get_expenses_summary();
            let mut exps_alt = doc_alt.get_expenses_summary();
            exps_server.sort_by(|a, b| a.id.cmp(&b.id));
            exps_alt.sort_by(|a, b| a.id.cmp(&b.id));
            prop_assert_eq!(exps_server, exps_alt);

            // Verify both docs have fully covered each other (cross deltas produce zero change)
            let diff_s_to_a = doc_server.diff_since_state_vector(&doc_alt.state_vector()).unwrap();
            let diff_a_to_s = doc_alt.diff_since_state_vector(&doc_server.state_vector()).unwrap();
            let sv_alt_before = doc_alt.state_vector();
            doc_alt.apply_update(&diff_s_to_a).unwrap();
            prop_assert_eq!(doc_alt.state_vector(), sv_alt_before);

            let sv_server_before = doc_server.state_vector();
            doc_server.apply_update(&diff_a_to_s).unwrap();
            prop_assert_eq!(doc_server.state_vector(), sv_server_before);
        }
    }
}
