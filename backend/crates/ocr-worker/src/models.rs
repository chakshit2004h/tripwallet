use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct ParsedLineItem {
    pub id: String,
    pub label: String,
    pub price_minor: i64,
    pub quantity: u32,
    pub confidence: f32,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct ParsedReceipt {
    pub title: String,
    pub currency: String,
    pub line_items: Vec<ParsedLineItem>,
    pub subtotal_minor: i64,
    pub tax_minor: i64,
    pub service_charge_minor: i64,
    pub total_minor: i64,
    pub confidence_overall: f32,
}
