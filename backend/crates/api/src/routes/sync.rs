use axum::{
    extract::{Path, State},
    http::StatusCode,
    response::IntoResponse,
    Json,
};
use base64::prelude::*;
use serde::{Deserialize, Serialize};
use uuid::Uuid;
use tripwallet_crdt_core::TripCrdtDoc;
use tripwallet_persistence::CrdtProjector;
use crate::state::AppState;

#[derive(Debug, Deserialize)]
pub struct SyncRequest {
    pub client_state_vector: String,
    pub pending_updates: Vec<String>,
}

#[derive(Debug, Serialize)]
pub struct SyncResponse {
    pub server_updates: Vec<String>,
    pub new_state_vector: String,
}

pub async fn handle_sync(
    State(state): State<AppState>,
    Path(trip_id): Path<String>,
    Json(payload): Json<SyncRequest>,
) -> Result<impl IntoResponse, (StatusCode, String)> {
    // 1. Decode client state vector
    let client_sv = BASE64_STANDARD
        .decode(&payload.client_state_vector)
        .map_err(|e| (StatusCode::BAD_REQUEST, format!("Invalid base64 state vector: {e}")))?;

    // 2. Load existing snapshot from DB or in-memory cache
    let existing_snapshot = {
        let mut found_bytes = None;
        if let Some(pool) = &state.db {
            if let Ok(trip_uuid) = Uuid::parse_str(&trip_id) {
                let row = sqlx::query_as::<_, (Option<Vec<u8>>,)>(
                    "SELECT crdt_snapshot FROM trips WHERE id = $1"
                )
                .bind(trip_uuid)
                .fetch_optional(pool)
                .await
                .ok()
                .flatten();

                if let Some((Some(bytes),)) = row {
                    found_bytes = Some(bytes);
                }
            }
        }

        if found_bytes.is_none() {
            let cache = state.in_memory_snapshots.read().await;
            found_bytes = cache.get(&trip_id).cloned();
        }

        found_bytes.unwrap_or_default()
    };

    // 3. Reconstruct doc and merge pending updates
    let doc = TripCrdtDoc::from_snapshot(&existing_snapshot)
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?;

    for update_str in &payload.pending_updates {
        if let Ok(update_bytes) = BASE64_STANDARD.decode(update_str) {
            if doc.apply_update(&update_bytes).is_ok() {
                // Broadcast this delta to active WebSocket trip members
                let _ = state.trip_broadcaster.send((trip_id.clone(), update_bytes));
            }
        }
    }

    // 4. Compute missing updates for this client
    let missing_for_client = doc
        .diff_since_state_vector(&client_sv)
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?;

    // 5. Persist updated snapshot
    let new_snapshot = doc.encode_snapshot();
    let new_sv = doc.state_vector();

    {
        let mut cache = state.in_memory_snapshots.write().await;
        cache.insert(trip_id.clone(), new_snapshot.clone());
    }

    if let Some(pool) = &state.db {
        if let Ok(trip_uuid) = Uuid::parse_str(&trip_id) {
            let _ = CrdtProjector::project_trip(pool, trip_uuid, &doc).await;
        }
    }

    let mut server_updates = Vec::new();
    if !missing_for_client.is_empty() && missing_for_client != vec![0] {
        server_updates.push(BASE64_STANDARD.encode(missing_for_client));
    }

    Ok((
        StatusCode::OK,
        Json(SyncResponse {
            server_updates,
            new_state_vector: BASE64_STANDARD.encode(new_sv),
        }),
    ))
}

#[cfg(test)]
mod tests {
    use super::*;
    use axum::{body::Body, http::Request, routing::post, Router};
    use tower::ServiceExt;

    #[tokio::test]
    async fn test_sync_endpoint_roundtrip() {
        let state = AppState::new(None);
        let app = Router::new()
            .route("/v1/trips/:id/sync", post(handle_sync))
            .with_state(state);

        let doc = TripCrdtDoc::new();
        let delta = doc.add_expense("e1", "Lunch", 1200, "INR", "m1", "equal").unwrap();
        let sv = doc.state_vector();

        let req_body = serde_json::json!({
            "client_state_vector": BASE64_STANDARD.encode(sv),
            "pending_updates": [BASE64_STANDARD.encode(delta)],
        });

        let response = app
            .oneshot(
                Request::builder()
                    .method("POST")
                    .uri("/v1/trips/test-trip/sync")
                    .header("content-type", "application/json")
                    .body(Body::from(serde_json::to_vec(&req_body).unwrap()))
                    .unwrap(),
            )
            .await
            .unwrap();

        assert_eq!(response.status(), StatusCode::OK);
    }
}
