use axum::{
    extract::{Path, State},
    http::StatusCode,
    response::IntoResponse,
    Json,
};
use serde::{Deserialize, Serialize};
use tripwallet_crdt_core::{SettlementSummary, TripCrdtDoc};
use crate::state::AppState;

#[derive(Debug, Deserialize)]
pub struct RecordSettlementRequest {
    pub id: String,
    pub from_member: String,
    pub to_member: String,
    pub amount_minor: i64,
    pub currency: Option<String>,
    pub method: Option<String>,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct SettlementResponse {
    pub success: bool,
    pub trip_id: String,
    pub settlement: SettlementSummary,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct ListSettlementsResponse {
    pub trip_id: String,
    pub settlements: Vec<SettlementSummary>,
}

pub async fn record_settlement(
    State(state): State<AppState>,
    Path(trip_id): Path<String>,
    Json(req): Json<RecordSettlementRequest>,
) -> Result<impl IntoResponse, (StatusCode, String)> {
    tracing::info!("Recording settlement {} for trip {}", req.id, trip_id);

    let currency = req.currency.unwrap_or_else(|| "INR".into());
    let method = req.method.unwrap_or_else(|| "upi".into());

    let mut cache = state.in_memory_snapshots.write().await;
    let existing_snapshot = cache.get(&trip_id).cloned().unwrap_or_default();

    let doc = TripCrdtDoc::from_snapshot(&existing_snapshot)
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?;

    doc.add_settlement(
        &req.id,
        &req.from_member,
        &req.to_member,
        req.amount_minor,
        &currency,
        &method,
    )
    .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?;

    let new_snapshot = doc.encode_snapshot();
    cache.insert(trip_id.clone(), new_snapshot);

    let summary = SettlementSummary {
        id: req.id,
        from_member: req.from_member,
        to_member: req.to_member,
        amount_minor: req.amount_minor,
        currency,
        method,
        status: "confirmed".into(),
    };

    Ok((
        StatusCode::OK,
        Json(SettlementResponse {
            success: true,
            trip_id,
            settlement: summary,
        }),
    ))
}

pub async fn list_settlements(
    State(state): State<AppState>,
    Path(trip_id): Path<String>,
) -> Result<impl IntoResponse, (StatusCode, String)> {
    let cache = state.in_memory_snapshots.read().await;
    let existing_snapshot = cache.get(&trip_id).cloned().unwrap_or_default();

    let doc = TripCrdtDoc::from_snapshot(&existing_snapshot)
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?;

    let settlements = doc.get_settlements_summary();

    Ok((
        StatusCode::OK,
        Json(ListSettlementsResponse {
            trip_id,
            settlements,
        }),
    ))
}

#[cfg(test)]
mod tests {
    use super::*;
    use axum::{body::Body, http::Request, routing::{get, post}, Router};
    use tower::ServiceExt;

    #[tokio::test]
    async fn test_record_and_list_settlements_roundtrip() {
        let state = AppState::new(None);
        let app = Router::new()
            .route("/v1/trips/:id/settlements", post(record_settlement))
            .route("/v1/trips/:id/settlements", get(list_settlements))
            .with_state(state);

        let req_body = serde_json::json!({
            "id": "set-101",
            "from_member": "m1",
            "to_member": "m2",
            "amount_minor": 85000,
            "currency": "INR",
            "method": "upi"
        });

        // 1. Record settlement
        let res_post = app
            .clone()
            .oneshot(
                Request::builder()
                    .method("POST")
                    .uri("/v1/trips/test-trip/settlements")
                    .header("content-type", "application/json")
                    .body(Body::from(serde_json::to_vec(&req_body).unwrap()))
                    .unwrap(),
            )
            .await
            .unwrap();

        assert_eq!(res_post.status(), StatusCode::OK);

        // 2. List settlements
        let res_get = app
            .oneshot(
                Request::builder()
                    .method("GET")
                    .uri("/v1/trips/test-trip/settlements")
                    .body(Body::empty())
                    .unwrap(),
            )
            .await
            .unwrap();

        assert_eq!(res_get.status(), StatusCode::OK);

        let body_bytes = axum::body::to_bytes(res_get.into_body(), 1024 * 1024).await.unwrap();
        let list_resp: ListSettlementsResponse = serde_json::from_slice(&body_bytes).unwrap();
        assert_eq!(list_resp.settlements.len(), 1);
        assert_eq!(list_resp.settlements[0].id, "set-101");
        assert_eq!(list_resp.settlements[0].amount_minor, 85000);
    }
}
