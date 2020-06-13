module Iom::PHP::Strtotime
  lookup_month_map : Hash(String, Int32) = {
    "jan" => 0_i32,
    "january" => 0_i32,
    "i" => 0_i32,
    "feb" => 1_i32,
    "february" => 1_i32,
    "ii" => 1_i32,
    "mar" => 2_i32,
    "march" => 2_i32,
    "iii" => 2_i32,
    "apr" => 3_i32,
    "april" => 3_i32,
    "iv" => 3_i32,
    "may" => 4_i32,
    "v" => 4_i32,
    "jun" => 5_i32,
    "june" => 5_i32,
    "vi" => 5_i32,
    "jul" => 6_i32,
    "july" => 6_i32,
    "vii" => 6_i32,
    "aug" => 7_i32,
    "august" => 7_i32,
    "viii" => 7_i32,
    "sep" => 8_i32,
    "sept" => 8_i32,
    "september" => 8_i32,
    "ix" => 8_i32,
    "oct" => 9_i32,
    "october" => 9_i32,
    "x" => 9_i32,
    "nov" => 10_i32,
    "november" => 10_i32,
    "xi" => 10_i32,
    "dec" => 11_i32,
    "december" => 11_i32,
    "xii" => 11_i32,
  }

  def lookup_month (month : String) : Int32?
    lookup_month_map[month.downcase]?
  end
end
