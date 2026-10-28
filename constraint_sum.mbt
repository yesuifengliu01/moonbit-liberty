///|
fn constraint_pair(a : Double, b : Double) -> Double {
  let value = a + b
  if value == 0.0 {
    0.0
  } else {
    value
  }
}

///|
/// Sum four finite binary64 constraint terms, rounding only the final result.
/// Each term is an integer multiple of 2^-1074. The signed base-2^30
/// accumulator has room for four maximum finite terms plus carry/sign space.
/// This is local to required/slack/period expressions; arrivals remain Double.
fn sum_constraints(a : Double, b : Double, c : Double, d : Double) -> Double {
  if a == -b {
    return constraint_pair(c, d)
  }
  if a == -c {
    return constraint_pair(b, d)
  }
  if a == -d {
    return constraint_pair(b, c)
  }
  if b == -c {
    return constraint_pair(a, d)
  }
  if b == -d {
    return constraint_pair(a, c)
  }
  if c == -d {
    return constraint_pair(a, b)
  }
  let one : UInt64 = 1
  let fraction_mask = (one << 52) - one
  let chunk_mask = (one << 30) - one
  let base : Int64 = 1073741824
  let limbs : Array[Int64] = Array::make(72, 0)
  for value in [a, b, c, d] {
    let bits = value.reinterpret_as_uint64()
    let exponent = ((bits >> 52) & 2047).to_int()
    let mantissa = (bits & fraction_mask) |
      (if exponent == 0 { 0 } else { one << 52 })
    let shift = if exponent == 0 { 0 } else { exponent - 1 }
    let index = shift / 30
    let offset = shift % 30
    let sign : Int64 = if bits >> 63 == 0 { 1 } else { -1 }
    limbs[index] += sign *
      ((mantissa & chunk_mask).reinterpret_as_int64() << offset)
    limbs[index + 1] += sign *
      ((mantissa >> 30).reinterpret_as_int64() << offset)
  }
  // Euclidean remainders retain negative carries without signed shifts.
  for i in 0..<(limbs.length() - 1) {
    let mut carry = limbs[i] / base
    let mut digit = limbs[i] % base
    if digit < 0 {
      digit += base
      carry -= 1
    }
    limbs[i] = digit
    limbs[i + 1] += carry
  }
  let negative = limbs[limbs.length() - 1] < 0
  if negative {
    for i in 0..<limbs.length() {
      limbs[i] = -limbs[i]
    }
    for i in 0..<(limbs.length() - 1) {
      let mut carry = limbs[i] / base
      let mut digit = limbs[i] % base
      if digit < 0 {
        digit += base
        carry -= 1
      }
      limbs[i] = digit
      limbs[i + 1] += carry
    }
  }
  let mut top = limbs.length() - 1
  while top > 0 && limbs[top] == 0 {
    top -= 1
  }
  if limbs[top] == 0 {
    return 0.0
  }
  let mut high = top * 30
  for bit in 0..<30 {
    if limbs[top] >> bit != 0 {
      high = top * 30 + bit
    }
  }
  let low = if high > 52 { high - 52 } else { 0 }
  let mut significand : UInt64 = 0
  for bit = high; bit >= low; bit = bit - 1 {
    significand = (significand << 1) |
      ((limbs[bit / 30] >> (bit % 30)).reinterpret_as_uint64() & one)
  }
  if low > 0 {
    let guard_bit = (limbs[(low - 1) / 30] >> ((low - 1) % 30)) & 1
    let mut sticky = false
    for bit in 0..<(low - 1) {
      if ((limbs[bit / 30] >> (bit % 30)) & 1) != 0 {
        sticky = true
        break
      }
    }
    if guard_bit != 0 && (sticky || (significand & one) != 0) {
      significand += one
      if significand == one << 53 {
        significand = significand >> 1
        high += 1
      }
    }
  }
  let sign = if negative { one << 63 } else { 0 }
  if high < 52 {
    return (sign | significand).reinterpret_as_double()
  }
  let exponent = high - 51
  if exponent >= 2047 {
    return (sign | (2047UL << 52)).reinterpret_as_double()
  }
  (sign |
  (Int64::from_int(exponent).reinterpret_as_uint64() << 52) |
  (significand & fraction_mask)).reinterpret_as_double()
}
