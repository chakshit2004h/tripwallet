use sqlx::{postgres::PgPoolOptions, PgPool};
use thiserror::Error;

#[derive(Error, Debug)]
pub enum DbError {
    #[error("Database error: {0}")]
    Sqlx(#[from] sqlx::Error),
    #[error("Migration error: {0}")]
    Migrate(#[from] sqlx::migrate::MigrateError),
}

pub async fn create_pool(database_url: &str, max_connections: u32) -> Result<PgPool, DbError> {
    let pool = PgPoolOptions::new()
        .max_connections(max_connections)
        .connect(database_url)
        .await?;

    Ok(pool)
}

pub async fn run_migrations(pool: &PgPool) -> Result<(), DbError> {
    sqlx::migrate!("./migrations")
        .run(pool)
        .await?;
    Ok(())
}
