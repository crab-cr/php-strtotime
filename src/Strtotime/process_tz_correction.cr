module Iom::PHP::Strtotime
  reTzCorrectionLoose : Regex = /(?:GMT)?([+-])(\d+)(:?)(\d{0,2})/i

  def self.process_tz_correction (tz_offset : String) : Int64
    tz_offset = tz_offset && reTzCorrectionLoose =~ tz_offset
  
    return old_value if !tz_offset
  
    sign = (tz_offset[1] == '-') ? 1 : -1
    hours = tz_offset[2].try(&.to_i16)
    minutes = tz_offset[4].try(&.to_i16)
  
    if !tz_offset[4] && !tz_offset[3]
      minutes = hours % 100
      hours = hours / 100
    end
  
    sign * (hours * 60 + minutes)
  end
end
