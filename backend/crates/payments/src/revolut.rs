use url::Url;
use tripwallet_domain::models::MinorUnits;

/// Generates a Revolut.me payment request link.
pub fn build_revolut_link(
    username: &str,
    amount: MinorUnits,
    currency: &str,
) -> String {
    let clean_user = username.trim_start_matches('@');
    let base = format!("https://revolut.me/{}", clean_user);
    let mut url = Url::parse(&base).expect("valid base url");
    let amount_str = amount.to_major_string(2);

    url.query_pairs_mut()
        .append_pair("amount", &amount_str)
        .append_pair("currency", currency);

    url.to_string()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_revolut_link_formatting() {
        let link = build_revolut_link("sarah_travels", MinorUnits::new(2800), "EUR");
        assert_eq!(link, "https://revolut.me/sarah_travels?amount=28.00&currency=EUR");
    }
}
