use sqlx::PgPool;
use uuid::Uuid;
use tripwallet_crdt_core::TripCrdtDoc;
use crate::db::DbError;

/// Materializes CRDT state into PostgreSQL relational tables.
pub struct CrdtProjector;

impl CrdtProjector {
    /// Saves the raw CRDT snapshot & state vector to the trip row,
    /// and upserts extracted expenses and members into relational tables.
    pub async fn project_trip(
        pool: &PgPool,
        trip_id: Uuid,
        doc: &TripCrdtDoc,
    ) -> Result<(), DbError> {
        let snapshot = doc.encode_snapshot();
        let state_vector = doc.state_vector();

        let mut tx = pool.begin().await?;

        // 1. Update trip snapshot and state vector
        sqlx::query(
            r#"
            UPDATE trips
            SET crdt_snapshot = $1,
                state_vector = $2,
                updated_at = NOW()
            WHERE id = $3
            "#,
        )
        .bind(snapshot)
        .bind(state_vector)
        .bind(trip_id)
        .execute(&mut *tx)
        .await?;

        // 2. Project expenses into relational table
        let expenses = doc.get_expenses_summary();
        for exp in expenses {
            if let Ok(exp_uuid) = Uuid::parse_str(&exp.id) {
                if let Ok(payer_uuid) = Uuid::parse_str(&exp.paid_by) {
                    sqlx::query(
                        r#"
                        INSERT INTO expenses (
                            id, trip_id, title, amount_minor, currency,
                            paid_by_member_id, split_method, created_by_member_id, updated_at
                        )
                        VALUES ($1, $2, $3, $4, $5, $6, $7, $6, NOW())
                        ON CONFLICT (id) DO UPDATE SET
                            title = EXCLUDED.title,
                            amount_minor = EXCLUDED.amount_minor,
                            currency = EXCLUDED.currency,
                            paid_by_member_id = EXCLUDED.paid_by_member_id,
                            split_method = EXCLUDED.split_method,
                            updated_at = NOW()
                        "#,
                    )
                    .bind(exp_uuid)
                    .bind(trip_id)
                    .bind(exp.title)
                    .bind(exp.amount_minor)
                    .bind(exp.currency)
                    .bind(payer_uuid)
                    .bind(exp.split_method)
                    .execute(&mut *tx)
                    .await?;
                }
            }
        }

        tx.commit().await?;
        Ok(())
    }
}
