module Iom::PHP::Strtotime
  def self.process_meridian (hour, meridian : String?)
    return hour if meridian.nil?
    meridian = meridian.downcase
    if meridian == "a"
      hour + ((hour == 12) ? -12 : 0) 
    elsif meridian == "p"
      hour + ((hour != 12) ? 12 : 0)
    else
      hour
    end
  end
end
