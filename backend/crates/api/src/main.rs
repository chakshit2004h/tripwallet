use axum::{routing::{get, post}, Router};
use std::net::SocketAddr;
use tower_http::trace::TraceLayer;
use tracing_subscriber::{layer::SubscriberExt, util::SubscriberInitExt};

mod state;
mod routes;

use state::AppState;

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    tracing_subscriber::registry()
        .with(
            tracing_subscriber::EnvFilter::try_from_default_env()
                .unwrap_or_else(|_| "tripwallet_api=debug,tower_http=debug".into()),
        )
        .with(tracing_subscriber::fmt::layer())
        .init();

    tracing::info!("Initializing TripWallet backend API...");

    // Database connection (optional in local dev without Docker running)
    let database_url = std::env::var("DATABASE_URL").ok();
    let db_pool = match database_url {
        Some(url) => {
            tracing::info!("Connecting to PostgreSQL...");
            match tripwallet_persistence::create_pool(&url, 5).await {
                Ok(pool) => {
                    tracing::info!("PostgreSQL connected successfully.");
                    Some(pool)
                }
                Err(e) => {
                    tracing::warn!("Could not connect to PostgreSQL: {e}. Starting in standalone mode.");
                    None
                }
            }
        }
        None => {
            tracing::info!("No DATABASE_URL set. Running in offline/in-memory mode.");
            None
        }
    };

    let app_state = AppState::new(db_pool);

    let app = Router::new()
        .route("/health", get(routes::health::health_check))
        .route("/ready", get(routes::health::readiness_check))
        .route("/v1/trips/:id/sync", post(routes::sync::handle_sync))
        .route("/v1/trips/:id/live", get(routes::ws::handle_ws_live))
        .route("/v1/trips/:id/receipts/parse", post(routes::receipts::handle_parse_receipt))
        .route("/v1/trips/:id/settlements", post(routes::settlements::record_settlement))
        .route("/v1/trips/:id/settlements", get(routes::settlements::list_settlements))
        .layer(TraceLayer::new_for_http())
        .with_state(app_state);

    let port: u16 = std::env::var("PORT")
        .unwrap_or_else(|_| "8080".into())
        .parse()
        .unwrap_or(8080);

    let addr = SocketAddr::from(([0, 0, 0, 0], port));
    tracing::info!("TripWallet API listening on http://{}", addr);

    let listener = tokio::net::TcpListener::bind(addr).await?;
    axum::serve(listener, app).await?;

    Ok(())
}
