module Iom::PHP::Strtotime
  lookup_weekday_map : Hash(String, Int16) = {
    "mon" => 1_i16,
    "monday" => 1_i16,
    "tue" => 2_i16,
    "tuesday" => 2_i16,
    "wed" => 3_i16,
    "wednesday" => 3_i16,
    "thu" => 4_i16,
    "thursday" => 4_i16,
    "fri" => 5_i16,
    "friday" => 5_i16,
    "sat" => 6_i16,
    "saturday" => 6_i16,
    "sun" => 0_i16,
    "sunday" => 0_i16,
  }

  def lookup_weekday (day_s : String, desired_sunday_number = 0_i16) : Int16
    day_s = day_s.downcase
    if lookup_weekday_map.has? day_s
      lookup_weekday_map[day_s]
    else
      desired_sunday_number
    end
  end
end
