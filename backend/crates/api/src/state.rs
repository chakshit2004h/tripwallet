use sqlx::PgPool;
use std::collections::HashMap;
use std::sync::Arc;
use tokio::sync::{broadcast, RwLock};

#[derive(Clone)]
pub struct AppState {
    pub db: Option<PgPool>,
    pub app_version: &'static str,
    /// Real-time fan-out channel: (trip_id, delta_bytes)
    pub trip_broadcaster: broadcast::Sender<(String, Vec<u8>)>,
    /// In-memory CRDT snapshot store (fallback / fast cache)
    pub in_memory_snapshots: Arc<RwLock<HashMap<String, Vec<u8>>>>,
}

impl AppState {
    pub fn new(db: Option<PgPool>) -> Self {
        let (tx, _rx) = broadcast::channel(1024);
        Self {
            db,
            app_version: env!("CARGO_PKG_VERSION"),
            trip_broadcaster: tx,
            in_memory_snapshots: Arc::new(RwLock::new(HashMap::new())),
        }
    }
}
