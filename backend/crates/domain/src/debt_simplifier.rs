use std::collections::{BinaryHeap, HashMap};
use serde::{Deserialize, Serialize};
use uuid::Uuid;
use crate::models::MinorUnits;

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct DebtTransfer {
    pub from_member: Uuid,
    pub to_member: Uuid,
    pub amount: MinorUnits,
}

/// Greedy minimum cash flow algorithm to simplify pairwise debts into minimal transfers.
pub fn simplify_debts(balances: &HashMap<Uuid, MinorUnits>) -> Vec<DebtTransfer> {
    // Binary heaps store: (value, member_id)
    // Debtors (balance < 0): we sort by largest debt first
    let mut debtors = BinaryHeap::new();
    // Creditors (balance > 0): we sort by largest credit first
    let mut creditors = BinaryHeap::new();

    for (&member, &balance) in balances {
        let val = balance.as_i64();
        if val < 0 {
            debtors.push((-val, member));
        } else if val > 0 {
            creditors.push((val, member));
        }
    }

    let mut transfers = Vec::new();

    while let (Some((debt, debtor)), Some((credit, creditor))) = (debtors.pop(), creditors.pop()) {
        let settled_amt = debt.min(credit);

        transfers.push(DebtTransfer {
            from_member: debtor,
            to_member: creditor,
            amount: MinorUnits::new(settled_amt),
        });

        let rem_debt = debt - settled_amt;
        let rem_credit = credit - settled_amt;

        if rem_debt > 0 {
            debtors.push((rem_debt, debtor));
        }
        if rem_credit > 0 {
            creditors.push((rem_credit, creditor));
        }
    }

    transfers
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_circular_debts_simplified() {
        let a = Uuid::new_v4();
        let b = Uuid::new_v4();
        let c = Uuid::new_v4();

        // A paid 30 for all 3 (A net +20, B net -10, C net -10)
        // B paid 15 for B and C (B net -10 + 7.5 = -2.5? Let's use exact integers)
        let mut balances = HashMap::new();
        balances.insert(a, MinorUnits::new(2000));
        balances.insert(b, MinorUnits::new(-1000));
        balances.insert(c, MinorUnits::new(-1000));

        let transfers = simplify_debts(&balances);
        assert_eq!(transfers.len(), 2);
        
        let total_settled: i64 = transfers.iter().map(|t| t.amount.as_i64()).sum();
        assert_eq!(total_settled, 2000);
    }

    #[test]
    fn test_perfectly_balanced_zero() {
        let a = Uuid::new_v4();
        let b = Uuid::new_v4();

        let mut balances = HashMap::new();
        balances.insert(a, MinorUnits::new(0));
        balances.insert(b, MinorUnits::new(0));

        let transfers = simplify_debts(&balances);
        assert!(transfers.is_empty());
    }
}
