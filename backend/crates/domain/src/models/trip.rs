use chrono::{DateTime, NaiveDate, Utc};
use serde::{Deserialize, Serialize};
use uuid::Uuid;

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub enum TripStatus {
    Active,
    Archived,
}

impl TripStatus {
    pub fn as_str(&self) -> &'static str {
        match self {
            TripStatus::Active => "active",
            TripStatus::Archived => "archived",
        }
    }
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub enum MemberRole {
    Creator,
    Member,
}

impl MemberRole {
    pub fn as_str(&self) -> &'static str {
        match self {
            MemberRole::Creator => "creator",
            MemberRole::Member => "member",
        }
    }
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct Trip {
    pub id: Uuid,
    pub name: String,
    pub start_date: Option<NaiveDate>,
    pub end_date: Option<NaiveDate>,
    pub base_currency: String,
    pub cover_image_url: Option<String>,
    pub created_by: Uuid,
    pub status: TripStatus,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct TripMember {
    pub id: Uuid,
    pub trip_id: Uuid,
    pub display_name: String,
    pub avatar_url: Option<String>,
    pub guest_token_id: Uuid,
    pub role: MemberRole,
    pub payment_vpa_encrypted: Option<String>,
    pub joined_at: DateTime<Utc>,
}
