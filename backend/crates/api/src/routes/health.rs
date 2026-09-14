use axum::{extract::State, http::StatusCode, response::IntoResponse, Json};
use serde_json::json;
use crate::state::AppState;

pub async fn health_check(State(state): State<AppState>) -> impl IntoResponse {
    (
        StatusCode::OK,
        Json(json!({
            "status": "healthy",
            "service": "tripwallet-api",
            "version": state.app_version,
        })),
    )
}

pub async fn readiness_check(State(state): State<AppState>) -> impl IntoResponse {
    let db_status = match &state.db {
        Some(pool) => {
            match sqlx::query("SELECT 1").execute(pool).await {
                Ok(_) => "connected",
                Err(_) => "disconnected",
            }
        }
        None => "not_configured",
    };

    let status_code = if db_status == "disconnected" {
        StatusCode::SERVICE_UNAVAILABLE
    } else {
        StatusCode::OK
    };

    (
        status_code,
        Json(json!({
            "status": if status_code == StatusCode::OK { "ready" } else { "unhealthy" },
            "database": db_status,
        })),
    )
}
