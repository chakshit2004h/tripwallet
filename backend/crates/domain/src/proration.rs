use std::collections::HashMap;
use uuid::Uuid;
use crate::models::MinorUnits;

#[derive(Debug, Clone)]
pub struct ClaimAllocation {
    pub member_id: Uuid,
    pub subtotal_minor: MinorUnits,
    pub tax_minor: MinorUnits,
    pub service_charge_minor: MinorUnits,
    pub total_minor: MinorUnits,
}

/// Prorates tax and service charge across members based on claimed item subtotals.
/// Any rounding residue (due to integer minor units) is deterministically assigned to the payer.
pub fn prorate_receipt(
    payer_id: Uuid,
    member_subtotals: &HashMap<Uuid, MinorUnits>,
    total_tax: MinorUnits,
    total_service_charge: MinorUnits,
) -> HashMap<Uuid, ClaimAllocation> {
    let grand_subtotal: i64 = member_subtotals.values().map(|m| m.as_i64()).sum();
    let mut result = HashMap::new();

    if grand_subtotal == 0 {
        return result;
    }

    let mut allocated_tax: i64 = 0;
    let mut allocated_service: i64 = 0;

    for (&member_id, &subtotal) in member_subtotals {
        let sub_val = subtotal.as_i64();
        // Proportion in basis points (using i128 to prevent overflow during intermediate multiplication)
        let member_tax = ((sub_val as i128 * total_tax.as_i64() as i128) / grand_subtotal as i128) as i64;
        let member_service = ((sub_val as i128 * total_service_charge.as_i64() as i128) / grand_subtotal as i128) as i64;

        allocated_tax += member_tax;
        allocated_service += member_service;

        result.insert(
            member_id,
            ClaimAllocation {
                member_id,
                subtotal_minor: subtotal,
                tax_minor: MinorUnits::new(member_tax),
                service_charge_minor: MinorUnits::new(member_service),
                total_minor: MinorUnits::new(sub_val + member_tax + member_service),
            },
        );
    }

    // Assign integer rounding residue to payer
    let residue_tax = total_tax.as_i64() - allocated_tax;
    let residue_service = total_service_charge.as_i64() - allocated_service;

    if let Some(payer_alloc) = result.get_mut(&payer_id) {
        payer_alloc.tax_minor += MinorUnits::new(residue_tax);
        payer_alloc.service_charge_minor += MinorUnits::new(residue_service);
        payer_alloc.total_minor += MinorUnits::new(residue_tax + residue_service);
    }

    result
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_exact_proration_with_residue() {
        let payer = Uuid::new_v4();
        let friend = Uuid::new_v4();

        let mut subtotals = HashMap::new();
        subtotals.insert(payer, MinorUnits::new(1000)); // 10.00
        subtotals.insert(friend, MinorUnits::new(2000)); // 20.00
        // Total subtotal = 3000

        let tax = MinorUnits::new(250); // 2.50 tax -> 1/3 payer (83.33 -> 83), 2/3 friend (166.66 -> 166). Residue 1 to payer.
        let service = MinorUnits::new(150); // 1.50 service -> 50 payer, 100 friend

        let allocations = prorate_receipt(payer, &subtotals, tax, service);

        let payer_alloc = &allocations[&payer];
        let friend_alloc = &allocations[&friend];

        assert_eq!(payer_alloc.tax_minor, MinorUnits::new(83 + 1)); // 84
        assert_eq!(friend_alloc.tax_minor, MinorUnits::new(166));

        // Invariance test: sum of totals must equal subtotal + tax + service
        let total_split: i64 = allocations.values().map(|a| a.total_minor.as_i64()).sum();
        assert_eq!(total_split, 3000 + 250 + 150);
    }

    use proptest::prelude::*;

    proptest! {
        #[test]
        fn test_proration_invariance_proptest(
            sub1 in 100i64..50_000,
            sub2 in 100i64..50_000,
            sub3 in 100i64..50_000,
            tax in 0i64..10_000,
            service in 0i64..10_000,
        ) {
            let p1 = Uuid::new_v4();
            let p2 = Uuid::new_v4();
            let p3 = Uuid::new_v4();

            let mut subtotals = HashMap::new();
            subtotals.insert(p1, MinorUnits::new(sub1));
            subtotals.insert(p2, MinorUnits::new(sub2));
            subtotals.insert(p3, MinorUnits::new(sub3));

            let total_tax = MinorUnits::new(tax);
            let total_service = MinorUnits::new(service);

            let allocs = prorate_receipt(p1, &subtotals, total_tax, total_service);

            let expected_grand_total = sub1 + sub2 + sub3 + tax + service;
            let actual_allocated_total: i64 = allocs.values().map(|a| a.total_minor.as_i64()).sum();

            prop_assert_eq!(actual_allocated_total, expected_grand_total);
        }
    }
}
