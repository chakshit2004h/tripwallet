use crate::models::{ParsedLineItem, ParsedReceipt};
use regex::Regex;
use uuid::Uuid;

pub struct ReceiptParser;

impl ReceiptParser {
    /// Returns a pre-configured sample parsed receipt based on preset key.
    pub fn get_sample(preset: &str) -> Option<ParsedReceipt> {
        match preset.to_lowercase().as_str() {
            "goa_shack" | "thalassa" | "dinner" => {
                let items = vec![
                    ParsedLineItem {
                        id: Uuid::new_v4().to_string(),
                        label: "Butter Chicken".into(),
                        price_minor: 60000,
                        quantity: 1,
                        confidence: 0.98,
                    },
                    ParsedLineItem {
                        id: Uuid::new_v4().to_string(),
                        label: "Garlic Naan (x2)".into(),
                        price_minor: 16000,
                        quantity: 2,
                        confidence: 0.96,
                    },
                    ParsedLineItem {
                        id: Uuid::new_v4().to_string(),
                        label: "Kingfisher Ultra (x3)".into(),
                        price_minor: 75000,
                        quantity: 3,
                        confidence: 0.99,
                    },
                    ParsedLineItem {
                        id: Uuid::new_v4().to_string(),
                        label: "Paneer Tikka".into(),
                        price_minor: 42000,
                        quantity: 1,
                        confidence: 0.97,
                    },
                    ParsedLineItem {
                        id: Uuid::new_v4().to_string(),
                        label: "Masala Papad".into(),
                        price_minor: 19000,
                        quantity: 1,
                        confidence: 0.95,
                    },
                ];
                let subtotal: i64 = items.iter().map(|i| i.price_minor).sum();
                let tax = 9600;
                let service = 19000;
                Some(ParsedReceipt {
                    title: "Thalassa Sunset Shack".into(),
                    currency: "INR".into(),
                    line_items: items,
                    subtotal_minor: subtotal,
                    tax_minor: tax,
                    service_charge_minor: service,
                    total_minor: subtotal + tax + service,
                    confidence_overall: 0.97,
                })
            }
            "bistro_brunch" | "cafe" | "brunch" => {
                let items = vec![
                    ParsedLineItem {
                        id: Uuid::new_v4().to_string(),
                        label: "Avocado Sourdough Toast".into(),
                        price_minor: 45000,
                        quantity: 1,
                        confidence: 0.99,
                    },
                    ParsedLineItem {
                        id: Uuid::new_v4().to_string(),
                        label: "Iced Cold Brew (x2)".into(),
                        price_minor: 44000,
                        quantity: 2,
                        confidence: 0.98,
                    },
                    ParsedLineItem {
                        id: Uuid::new_v4().to_string(),
                        label: "Parmesan Truffle Fries".into(),
                        price_minor: 38000,
                        quantity: 1,
                        confidence: 0.97,
                    },
                    ParsedLineItem {
                        id: Uuid::new_v4().to_string(),
                        label: "Almond Croissant".into(),
                        price_minor: 24000,
                        quantity: 1,
                        confidence: 0.96,
                    },
                ];
                let subtotal: i64 = items.iter().map(|i| i.price_minor).sum();
                let tax = 7550;
                let service = 12000;
                Some(ParsedReceipt {
                    title: "Blue Tokai Roasters".into(),
                    currency: "INR".into(),
                    line_items: items,
                    subtotal_minor: subtotal,
                    tax_minor: tax,
                    service_charge_minor: service,
                    total_minor: subtotal + tax + service,
                    confidence_overall: 0.98,
                })
            }
            "late_night_pizza" | "pizza" => {
                let items = vec![
                    ParsedLineItem {
                        id: Uuid::new_v4().to_string(),
                        label: "Margherita D.O.P.".into(),
                        price_minor: 55000,
                        quantity: 1,
                        confidence: 0.99,
                    },
                    ParsedLineItem {
                        id: Uuid::new_v4().to_string(),
                        label: "Spicy Pepperoni Pizza".into(),
                        price_minor: 65000,
                        quantity: 1,
                        confidence: 0.99,
                    },
                    ParsedLineItem {
                        id: Uuid::new_v4().to_string(),
                        label: "Garlic Butter Crust Bites".into(),
                        price_minor: 22000,
                        quantity: 1,
                        confidence: 0.95,
                    },
                    ParsedLineItem {
                        id: Uuid::new_v4().to_string(),
                        label: "Classic Tiramisu".into(),
                        price_minor: 32000,
                        quantity: 1,
                        confidence: 0.97,
                    },
                ];
                let subtotal: i64 = items.iter().map(|i| i.price_minor).sum();
                let tax = 8700;
                let service = 17400;
                Some(ParsedReceipt {
                    title: "Leo's Artisan Pizzeria".into(),
                    currency: "INR".into(),
                    line_items: items,
                    subtotal_minor: subtotal,
                    tax_minor: tax,
                    service_charge_minor: service,
                    total_minor: subtotal + tax + service,
                    confidence_overall: 0.98,
                })
            }
            _ => None,
        }
    }

    /// Parses raw lines of text into structured items, tax, and service charges.
    pub fn parse_text(raw_text: &str) -> ParsedReceipt {
        // Regex for price at the end of a line: e.g. "₹600.00", "12.50", "250", "$ 14.99"
        let price_re = Regex::new(r"[\$€£₹]?\s*([0-9]+(?:[.,][0-9]{2})?)\s*$").unwrap();
        // Regex for quantity at the start: e.g. "2x ", "2 x ", "1 "
        let qty_re = Regex::new(r"^(?:(\d+)\s*[xX]?\s+)?(.*)$").unwrap();

        let mut line_items = Vec::new();
        let mut detected_subtotal = 0i64;
        let mut detected_tax = 0i64;
        let mut detected_service = 0i64;
        let mut detected_title = "Scanned Receipt".to_string();

        let lines: Vec<&str> = raw_text.lines().map(|l| l.trim()).filter(|l| !l.is_empty()).collect();

        if let Some(first_line) = lines.first() {
            if !first_line.is_empty() && !first_line.chars().any(|c| c.is_ascii_digit()) {
                detected_title = first_line.to_string();
            }
        }

        for line in &lines {
            let lower = line.to_lowercase();

            if let Some(caps) = price_re.captures(line) {
                let price_str = &caps[1].replace(',', ".");
                let price_float: f64 = price_str.parse().unwrap_or(0.0);
                let price_minor = (price_float * 100.0).round() as i64;

                // Strip the trailing price to get label
                let label_part = line[..caps.get(0).unwrap().start()].trim().trim_end_matches(['-', ':']);

                if lower.contains("tax") || lower.contains("gst") || lower.contains("cgst") || lower.contains("sgst") || lower.contains("vat") {
                    detected_tax += price_minor;
                } else if lower.contains("service") || lower.contains("tip") || lower.contains("gratuity") {
                    detected_service += price_minor;
                } else if lower.contains("subtotal") || lower.contains("sub-total") || lower.contains("sub total") {
                    detected_subtotal = price_minor;
                } else if lower.contains("total") || lower.contains("amount due") {
                    // grand total line, ignore for line item extraction
                } else if !label_part.is_empty() {
                    let (qty, clean_label) = if let Some(q_caps) = qty_re.captures(label_part) {
                        let q = q_caps.get(1).and_then(|m| m.as_str().parse::<u32>().ok()).unwrap_or(1);
                        let l = q_caps.get(2).map(|m| m.as_str().trim()).unwrap_or(label_part);
                        (q, l.to_string())
                    } else {
                        (1, label_part.to_string())
                    };

                    line_items.push(ParsedLineItem {
                        id: Uuid::new_v4().to_string(),
                        label: clean_label,
                        price_minor,
                        quantity: qty,
                        confidence: 0.94,
                    });
                }
            }
        }

        let calculated_subtotal: i64 = line_items.iter().map(|i| i.price_minor).sum();
        let subtotal = if detected_subtotal > 0 { detected_subtotal } else { calculated_subtotal };
        let total = subtotal + detected_tax + detected_service;

        ParsedReceipt {
            title: detected_title,
            currency: "INR".into(),
            line_items,
            subtotal_minor: subtotal,
            tax_minor: detected_tax,
            service_charge_minor: detected_service,
            total_minor: total,
            confidence_overall: 0.95,
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_sample_presets() {
        let receipt = ReceiptParser::get_sample("goa_shack").expect("Should find preset");
        assert_eq!(receipt.title, "Thalassa Sunset Shack");
        assert_eq!(receipt.line_items.len(), 5);
        assert_eq!(receipt.total_minor, receipt.subtotal_minor + receipt.tax_minor + receipt.service_charge_minor);

        let brunch = ReceiptParser::get_sample("bistro_brunch").expect("Should find preset");
        assert_eq!(brunch.line_items.len(), 4);
        assert_eq!(brunch.total_minor, brunch.subtotal_minor + brunch.tax_minor + brunch.service_charge_minor);
    }

    #[test]
    fn test_parse_raw_text() {
        let text = r#"
        Cafe Bistro Deluxe
        2x Cappuccino 300.00
        1x Truffle Toast 450.00
        CGST 5% 37.50
        Service Charge 75.00
        Total 862.50
        "#;

        let receipt = ReceiptParser::parse_text(text);
        assert_eq!(receipt.title, "Cafe Bistro Deluxe");
        assert_eq!(receipt.line_items.len(), 2);
        assert_eq!(receipt.line_items[0].label, "Cappuccino");
        assert_eq!(receipt.line_items[0].quantity, 2);
        assert_eq!(receipt.line_items[0].price_minor, 30000);
        assert_eq!(receipt.line_items[1].label, "Truffle Toast");
        assert_eq!(receipt.line_items[1].price_minor, 45000);
        assert_eq!(receipt.tax_minor, 3750);
        assert_eq!(receipt.service_charge_minor, 7500);
        assert_eq!(receipt.total_minor, 30000 + 45000 + 3750 + 7500);
    }
}
