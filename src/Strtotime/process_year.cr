module Iom::PHP::Strtotime
  def process_year (year_s : String?) : Int16
    year : Int16 = year.to_i16

    if (year_s.size < 4 && year < 100)
      year += year < 70 ? 2000 : 1900
    end

    year
  end
end
