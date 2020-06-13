private LOOKUP_MONTH_MAP = {
  # JavaScript Jan starts with 0
  "jan" => 1_i32,
  "january" => 1_i32,
  "i" => 1_i32,
  "feb" => 2_i32,
  "february" => 2_i32,
  "ii" => 2_i32,
  "mar" => 3_i32,
  "march" => 3_i32,
  "iii" => 3_i32,
  "apr" => 4_i32,
  "april" => 4_i32,
  "iv" => 4_i32,
  "may" => 5_i32,
  "v" => 5_i32,
  "jun" => 6_i32,
  "june" => 6_i32,
  "vi" => 6_i32,
  "jul" => 7_i32,
  "july" => 7_i32,
  "vii" => 7_i32,
  "aug" => 8_i32,
  "august" => 8_i32,
  "viii" => 8_i32,
  "sep" => 9_i32,
  "sept" => 9_i32,
  "september" => 9_i32,
  "ix" => 9_i32,
  "oct" => 10_i32,
  "october" => 10_i32,
  "x" => 10_i32,
  "nov" => 11_i32,
  "november" => 11_i32,
  "xi" => 11_i32,
  "dec" => 12_i32,
  "december" => 12_i32,
  "xii" => 12_i32,
}

module Iom::PHP::Strtotime
  def self.lookup_month (month : String) : Int32?
    LOOKUP_MONTH_MAP[month.downcase]?
  end
end
