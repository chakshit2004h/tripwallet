use url::Url;
use tripwallet_domain::models::MinorUnits;

/// Generates an Indian Unified Payments Interface (UPI) intent URI.
/// Supported natively by Google Pay, PhonePe, Paytm, BHIM, CRED, etc.
pub fn build_upi_intent_uri(
    payee_vpa: &str,
    payee_name: &str,
    amount: MinorUnits,
    note: Option<&str>,
) -> String {
    let mut url = Url::parse("upi://pay").expect("valid base scheme");
    let amount_str = amount.to_major_string(2);

    url.query_pairs_mut()
        .append_pair("pa", payee_vpa)
        .append_pair("pn", payee_name)
        .append_pair("am", &amount_str)
        .append_pair("cu", "INR");

    if let Some(n) = note {
        url.query_pairs_mut().append_pair("tn", n);
    }

    url.to_string()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_upi_intent_formatting() {
        let uri = build_upi_intent_uri(
            "rahul@okhdfcbank",
            "Rahul Sharma",
            MinorUnits::new(145050), // ₹1450.50
            Some("Dinner split - TripWallet"),
        );
        assert!(uri.starts_with("upi://pay?"));
        assert!(uri.contains("pa=rahul%40okhdfcbank"));
        assert!(uri.contains("pn=Rahul+Sharma"));
        assert!(uri.contains("am=1450.50"));
        assert!(uri.contains("cu=INR"));
        assert!(uri.contains("tn=Dinner+split+-+TripWallet"));
    }
}
