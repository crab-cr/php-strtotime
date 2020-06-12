module Iom::PHP::Strtotime
  lookup_month_map : Hash(String, Int16) = {
    "jan" => 0_i16,
    "january" => 0_i16,
    "i" => 0_i16,
    "feb" => 1_i16,
    "february" => 1_i16,
    "ii" => 1_i16,
    "mar" => 2_i16,
    "march" => 2_i16,
    "iii" => 2_i16,
    "apr" => 3_i16,
    "april" => 3_i16,
    "iv" => 3_i16,
    "may" => 4_i16,
    "v" => 4_i16,
    "jun" => 5_i16,
    "june" => 5_i16,
    "vi" => 5_i16,
    "jul" => 6_i16,
    "july" => 6_i16,
    "vii" => 6_i16,
    "aug" => 7_i16,
    "august" => 7_i16,
    "viii" => 7_i16,
    "sep" => 8_i16,
    "sept" => 8_i16,
    "september" => 8_i16,
    "ix" => 8_i16,
    "oct" => 9_i16,
    "october" => 9_i16,
    "x" => 9_i16,
    "nov" => 10_i16,
    "november" => 10_i16,
    "xi" => 10_i16,
    "dec" => 11_i16,
    "december" => 11_i16,
    "xii" => 11_i16,
  }

  def lookup_month (year_s : String) : Int16
    year : Int16 = year.try(&.to_i16) || 0_i16

    if year_s.size < 4 && year < 100
      year + ((year < 70) ? 2000 : 1900)
    else
      year
    end

  end
end
