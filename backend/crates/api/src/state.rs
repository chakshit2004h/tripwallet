use sqlx::PgPool;

#[derive(Clone)]
pub struct AppState {
    pub db: Option<PgPool>,
    pub app_version: &'static str,
}

impl AppState {
    pub fn new(db: Option<PgPool>) -> Self {
        Self {
            db,
            app_version: env!("CARGO_PKG_VERSION"),
        }
    }
}
