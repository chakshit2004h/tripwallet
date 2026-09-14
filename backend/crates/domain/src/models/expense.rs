use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use uuid::Uuid;
use super::money::MinorUnits;

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub enum SplitMethod {
    Equal,
    Percentage,
    Shares,
    Exact,
    Itemized,
}

impl SplitMethod {
    pub fn as_str(&self) -> &'static str {
        match self {
            SplitMethod::Equal => "equal",
            SplitMethod::Percentage => "percentage",
            SplitMethod::Shares => "shares",
            SplitMethod::Exact => "exact",
            SplitMethod::Itemized => "itemized",
        }
    }
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct Expense {
    pub id: Uuid,
    pub trip_id: Uuid,
    pub title: String,
    pub amount_minor: MinorUnits,
    pub currency: String,
    pub paid_by_member_id: Uuid,
    pub split_method: SplitMethod,
    pub receipt_image_url: Option<String>,
    pub tax_minor: MinorUnits,
    pub service_charge_minor: MinorUnits,
    pub created_by_member_id: Uuid,
    pub created_at: DateTime<Utc>,
    pub deleted_at: Option<DateTime<Utc>>,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct ExpenseLineItem {
    pub id: Uuid,
    pub expense_id: Uuid,
    pub label: String,
    pub price_minor: MinorUnits,
    pub ocr_confidence: f32,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct ItemClaim {
    pub id: Uuid,
    pub line_item_id: Uuid,
    pub member_id: Uuid,
    pub share_fraction: f64,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct ExpenseSplit {
    pub id: Uuid,
    pub expense_id: Uuid,
    pub member_id: Uuid,
    pub amount_minor: MinorUnits,
}
