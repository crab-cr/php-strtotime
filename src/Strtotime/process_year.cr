module Iom::PHP::Strtotime
  def self.process_year (year_s : String?) : Int32
    year : Int32 = year_s.try(&.to_i32)

    if (year_s.size < 4 && year < 100)
      year += year < 70 ? 2000 : 1900
    end

    year
  end
end
