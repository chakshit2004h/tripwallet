use axum::{
    extract::{Path, State},
    http::StatusCode,
    response::IntoResponse,
    Json,
};
use serde::{Deserialize, Serialize};
use tripwallet_ocr_worker::{ParsedReceipt, ReceiptParser};
use crate::state::AppState;

#[derive(Debug, Deserialize)]
pub struct ParseReceiptRequest {
    pub raw_text: Option<String>,
    pub sample_preset: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ParseReceiptResponse {
    pub success: bool,
    pub trip_id: String,
    pub receipt: ParsedReceipt,
}

pub async fn handle_parse_receipt(
    State(_state): State<AppState>,
    Path(trip_id): Path<String>,
    Json(req): Json<ParseReceiptRequest>,
) -> Result<impl IntoResponse, (StatusCode, String)> {
    tracing::info!("Received receipt parse request for trip {trip_id}");

    let parsed = if let Some(preset) = req.sample_preset {
        ReceiptParser::get_sample(&preset).unwrap_or_else(|| {
            ReceiptParser::get_sample("goa_shack").expect("Default preset must exist")
        })
    } else if let Some(text) = req.raw_text {
        ReceiptParser::parse_text(&text)
    } else {
        ReceiptParser::get_sample("goa_shack").expect("Default preset must exist")
    };

    Ok((
        StatusCode::OK,
        Json(ParseReceiptResponse {
            success: true,
            trip_id,
            receipt: parsed,
        }),
    ))
}

#[cfg(test)]
mod tests {
    use super::*;
    use axum::{body::Body, http::Request, routing::post, Router};
    use tower::ServiceExt;

    #[tokio::test]
    async fn test_parse_sample_receipt_preset() {
        let state = AppState::new(None);
        let app = Router::new()
            .route("/v1/trips/:id/receipts/parse", post(handle_parse_receipt))
            .with_state(state);

        let req_body = serde_json::json!({
            "sample_preset": "goa_shack"
        });

        let response = app
            .oneshot(
                Request::builder()
                    .method("POST")
                    .uri("/v1/trips/trip-123/receipts/parse")
                    .header("content-type", "application/json")
                    .body(Body::from(serde_json::to_vec(&req_body).unwrap()))
                    .unwrap(),
            )
            .await
            .unwrap();

        assert_eq!(response.status(), StatusCode::OK);

        let body_bytes = axum::body::to_bytes(response.into_body(), 1024 * 1024).await.unwrap();
        let resp: ParseReceiptResponse = serde_json::from_slice(&body_bytes).unwrap();
        assert!(resp.success);
        assert_eq!(resp.trip_id, "trip-123");
        assert_eq!(resp.receipt.title, "Thalassa Sunset Shack");
        assert_eq!(resp.receipt.line_items.len(), 5);
        assert_eq!(resp.receipt.total_minor, 240600); // 212000 sub + 9600 tax + 19000 service
    }

    #[tokio::test]
    async fn test_parse_raw_text_receipt() {
        let state = AppState::new(None);
        let app = Router::new()
            .route("/v1/trips/:id/receipts/parse", post(handle_parse_receipt))
            .with_state(state);

        let req_body = serde_json::json!({
            "raw_text": "Burger House\n1x Cheeseburger 350.00\n1x Fries 150.00\nGST 25.00\nTotal 525.00"
        });

        let response = app
            .oneshot(
                Request::builder()
                    .method("POST")
                    .uri("/v1/trips/trip-123/receipts/parse")
                    .header("content-type", "application/json")
                    .body(Body::from(serde_json::to_vec(&req_body).unwrap()))
                    .unwrap(),
            )
            .await
            .unwrap();

        assert_eq!(response.status(), StatusCode::OK);

        let body_bytes = axum::body::to_bytes(response.into_body(), 1024 * 1024).await.unwrap();
        let resp: ParseReceiptResponse = serde_json::from_slice(&body_bytes).unwrap();
        assert_eq!(resp.receipt.line_items.len(), 2);
        assert_eq!(resp.receipt.total_minor, 52500);
    }
}
