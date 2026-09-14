use std::fmt;
use std::ops::{Add, AddAssign, Sub, SubAssign};
use serde::{Deserialize, Serialize};

/// Represents currency amounts in integer minor units (paise, cents).
/// Prevents floating-point rounding issues in financial calculations.
#[derive(Debug, Clone, Copy, PartialEq, Eq, PartialOrd, Ord, Hash, Serialize, Deserialize, Default)]
pub struct MinorUnits(pub i64);

impl MinorUnits {
    pub const ZERO: Self = Self(0);

    pub fn new(amount: i64) -> Self {
        Self(amount)
    }

    pub fn as_i64(&self) -> i64 {
        self.0
    }

    pub fn to_major_string(&self, decimal_places: u8) -> String {
        let divisor = 10_i64.pow(decimal_places as u32);
        let major = self.0 / divisor;
        let minor = (self.0 % divisor).abs();
        format!("{}.{:0width$}", major, minor, width = decimal_places as usize)
    }
}

impl Add for MinorUnits {
    type Output = Self;
    fn add(self, rhs: Self) -> Self::Output {
        Self(self.0 + rhs.0)
    }
}

impl AddAssign for MinorUnits {
    fn add_assign(&mut self, rhs: Self) {
        self.0 += rhs.0;
    }
}

impl Sub for MinorUnits {
    type Output = Self;
    fn sub(self, rhs: Self) -> Self::Output {
        Self(self.0 - rhs.0)
    }
}

impl SubAssign for MinorUnits {
    fn sub_assign(&mut self, rhs: Self) {
        self.0 -= rhs.0;
    }
}

impl fmt::Display for MinorUnits {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{}", self.0)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_minor_units_arithmetic() {
        let a = MinorUnits::new(1500); // e.g. $15.00 or ₹15.00
        let b = MinorUnits::new(750);  // $7.50
        assert_eq!(a + b, MinorUnits::new(2250));
        assert_eq!(a - b, MinorUnits::new(750));
        assert_eq!(a.to_major_string(2), "15.00");
        assert_eq!(b.to_major_string(2), "7.50");
    }
}
