# require "./formats_parts"

private RE_SPACE = "[ \\t]+"
private RE_SPACE_OPT = "[ \\t]*"
private RE_MERIDIAN = "(?:([ap])\\.?m\\.?([\\t ]|$))"
private RE_HOUR_24 = "(2[0-4]|[01]?[0-9])"
private RE_HOUR_24_LZ = "([01][0-9]|2[0-4])"
private RE_HOUR_12 = "(0?[1-9]|1[0-2])"
private RE_MINUTE = "([0-5]?[0-9])"
private RE_MINUTE_LZ = "([0-5][0-9])"
private RE_SECOND = "(60|[0-5]?[0-9])"
private RE_SECOND_LZ = "(60|[0-5][0-9])"
private RE_FRAC = "(?:\\.([0-9]+))"

private RE_DAY_FULL = "sunday|monday|tuesday|wednesday|thursday|friday|saturday"
private RE_DAY_ABBR = "sun|mon|tue|wed|thu|fri|sat"
private RE_DAY_TEXT = RE_DAY_FULL + "|" + RE_DAY_ABBR + "|weekdays?"

private RE_REL_TEXT_NUM = "first|second|third|fourth|fifth|sixth|seventh|eighth?|ninth|tenth|eleventh|twelfth"
private RE_REL_TEXT_TEXT = "next|last|previous|this"
private RE_REL_TEXT_UNIT = "(?:second|sec|minute|min|hour|day|fortnight|forthnight|month|year)s?|weeks|" + RE_DAY_TEXT

private RE_YEAR = "([0-9]{1,4})"
private RE_YEAR2 = "([0-9]{2})"
private RE_YEAR4 = "([0-9]{4})"
private RE_YEAR4_WITH_SIGN = "([+-]?[0-9]{4})"
private RE_MONTH = "(1[0-2]|0?[0-9])"
private RE_MONTH_LZ = "(0[0-9]|1[0-2])"
private RE_DAY = "(?:(3[01]|[0-2]?[0-9])(?:st|nd|rd|th)?)"
private RE_DAY_LZ = "(0[0-9]|[1-2][0-9]|3[01])"

private RE_MONTH_FULL = "january|february|march|april|may|june|july|august|september|october|november|december"
private RE_MONTH_ABBR = "jan|feb|mar|apr|may|jun|jul|aug|sept?|oct|nov|dec"
private RE_MONTH_ROMAN = "i[vx]|vi{0,3}|xi{0,2}|i{1,3}"
private RE_MONTH_TEXT = "(" + RE_MONTH_FULL + "|" + RE_MONTH_ABBR + "|" + RE_MONTH_ROMAN + ")"

private RE_TZ_CORRECTION = "((?:GMT)?([+-])" + RE_HOUR_24 + ":?" + RE_MINUTE + "?)"
private RE_DAY_OF_YEAR = "(00[1-9]|0[1-9][0-9]|[12][0-9][0-9]|3[0-5][0-9]|36[0-6])"
private RE_WEEK_OF_YEAR = "(0[1-9]|[1-4][0-9]|5[0-3])"

private RE_DATE_NO_YEAR = RE_MONTH_TEXT + "[ .\\t-]*" + RE_DAY + "[,.stndrh\\t ]*"

module Iom::PHP::Strtotime::Formats

  abstract class BaseFormatParser
  end
  
  module BaseFormatParserGetters
    property regex : Regex
    property name : String
  end

  class Yesterday < BaseFormatParser
    include BaseFormatParserGetters
    def initialize
      @regex = /^yesterday/i
      @name = "yesterday"
    end
    def callback (rb : ResultBuilder, match : Regex::MatchData)
      # puts "format_parser:#{@name}:#{__LINE__} #{rb.rd}"
      rb.rd -= 1
      # puts "format_parser:#{@name}:#{__LINE__} #{rb.rd}"
      return rb.resetTime()
    end
  end

  class Now < BaseFormatParser
    include BaseFormatParserGetters
    def initialize
      @regex = /^now/i
      @name = "now"
    end
    def callback (rb : ResultBuilder, match : Regex::MatchData)
      # do nothing
    end
  end

  class Noon < BaseFormatParser
    include BaseFormatParserGetters
    def initialize
      @regex = /^noon/i
      @name = "noon"
    end
    def callback (rb : ResultBuilder, match : Regex::MatchData)
      return rb.resetTime() && rb.time(12, 0, 0, 0)
    end
  end

  class MidnightOrToday < BaseFormatParser
    include BaseFormatParserGetters
    def initialize
      @regex = /^(midnight|today)/i
      @name = "midnight | today"
    end
    def callback (rb : ResultBuilder, match : Regex::MatchData)
      return rb.resetTime()
    end
  end

  class Tomorrow < BaseFormatParser
    include BaseFormatParserGetters
    def initialize
      @regex = /^tomorrow/i
      @name = "tomorrow"
    end
    def callback (rb : ResultBuilder, match : Regex::MatchData)
      rb.rd += 1
      return rb.resetTime()
    end
  end

  class Timestamp < BaseFormatParser
    include BaseFormatParserGetters
    def initialize
      @regex = /^@(-?\d+)/i
      @name = "timestamp"
    end
    def callback (rb : ResultBuilder, match : Regex::MatchData)
      rb.reset_as Time.unix(match[1]?.try(&.to_i32) || 0)
    end
  end

  class FirstOrLastDay < BaseFormatParser
    include BaseFormatParserGetters
    def initialize
      @regex = /^(first|last) day of/i
      @name = "firstdayof | lastdayof"
    end
    def callback (rb : ResultBuilder, match : Regex::MatchData)
      day : String = match[1]
      if day.downcase == "first"
        rb.first_or_last_day_of_month = 1
      else
        rb.first_or_last_day_of_month = -1
      end
    end
  end

  class BackOrFrontOf < BaseFormatParser
    include BaseFormatParserGetters
    def initialize
      @regex = Regex.new("^(back|front) of " + RE_HOUR_24 + RE_SPACE_OPT + RE_MERIDIAN + "?", Regex::Options::IGNORE_CASE)
      @name = "backof | frontof"
    end
    def callback (rb : ResultBuilder, match : Regex::MatchData)
      side : String = match[1]? || ""
      hour : Int32 = match[2]?.try(&.to_i32) || 0
      meridian : String = match[3]? || ""
      back : Bool = side.downcase == "back"
      minute = 15

      if !back
        hour -= 1
        minute = 45
      end

      hour = Iom::PHP::Strtotime.process_meridian(hour, meridian)

      return rb.resetTime() && rb.time(hour, minute, 0, 0)
    end
  end

  # class WeekdayOf < BaseFormatParser
  #   include BaseFormatParserGetters
  #   def initialize
  #     @regex = Regex.new("^(" + RE_REL_TEXT_NUM + "|" + RE_REL_TEXT_TEXT + ")" + RE_SPACE + "(" + RE_DAY_FULL + "|" + RE_DAY_ABBR + ")" + RE_SPACE + "of", Regex::Options::IGNORE_CASE)
  #     @name = "weekdayo"
  #   end
  #   def callback (rb : ResultBuilder, match : Regex::MatchData)
  #     # todo
  #   end
  # end

  # class Mssqltime < BaseFormatParser
  #   include BaseFormatParserGetters
  #   def initialize
  #     @regex = Regex.new("^" + RE_HOUR_12 + ":" + RE_MINUTE_LZ + ":" + RE_SECOND_LZ + "[:.]([0-9]+)" + RE_MERIDIAN, Regex::Options::IGNORE_CASE)
  #     @name = "mssqltime"
  #   end
  #   def callback (rb : ResultBuilder, match : Regex::MatchData)
  #     hour : Int32 = match[1].try(&.to_i32) || 0
  #     minute : Int32 = match[2].try(&.to_i32) || 0
  #     second : Int32 = match[3].try(&.to_i32) || 0
  #     frac : Int32 = match[4][0,3].try(&.to_i32) || 0
  #     meridian : String = match[5]? || ""
  #     return rb.time(
  #       Iom::PHP::Strtotime.process_meridian(hour, meridian),
  #       minute,
  #       second,
  #       frac)
  #   end
  # end

  class TimeLong12 < BaseFormatParser
    include BaseFormatParserGetters
    def initialize
      @regex = Regex.new("^" + RE_HOUR_12 + "[:.]" + RE_MINUTE + "[:.]" + RE_SECOND_LZ + RE_SPACE_OPT + RE_MERIDIAN, Regex::Options::IGNORE_CASE)
      @name = "timelong12"
    end
    def callback (rb : ResultBuilder, match : Regex::MatchData)
      hour : Int32 = match[1].try(&.to_i32) || 0
      minute : Int32 = match[2].try(&.to_i32) || 0
      second : Int32 = match[3].try(&.to_i32) || 0
      frac : Int32 = 0
      meridian : String = match[5]? || ""
      return rb.time(
        Iom::PHP::Strtotime.process_meridian(hour, meridian),
        minute,
        second,
        frac)
    end
  end

  class TimeShort12 < BaseFormatParser
    include BaseFormatParserGetters
    def initialize
      @regex = Regex.new("^" + RE_HOUR_12 + "[:.]" + RE_MINUTE_LZ + RE_SPACE_OPT + RE_MERIDIAN, Regex::Options::IGNORE_CASE)
      @name = "timeshort12"
    end
    def callback (rb : ResultBuilder, match : Regex::MatchData)
      hour : Int32 = match[1].try(&.to_i32) || 0
      minute : Int32 = match[2].try(&.to_i32) || 0
      second : Int32 = 0
      frac : Int32 = 0
      meridian : String = match[5]? || ""
      return rb.time(
        Iom::PHP::Strtotime.process_meridian(hour, meridian),
        minute,
        second,
        frac)
    end
  end

  class TimeTiny12 < BaseFormatParser
    include BaseFormatParserGetters
    def initialize
      @regex = Regex.new("^" + RE_HOUR_12 + RE_SPACE_OPT + RE_MERIDIAN, Regex::Options::IGNORE_CASE)
      @name = "timetiny12"
    end
    def callback (rb : ResultBuilder, match : Regex::MatchData)
      hour : Int32 = match[1].try(&.to_i32) || 0
      minute : Int32 = 0
      second : Int32 = 0
      frac : Int32 = 0
      meridian : String = match[5]? || ""
      return rb.time(
        Iom::PHP::Strtotime.process_meridian(hour, meridian),
        minute,
        second,
        frac)
    end
  end

  # class Soap < BaseFormatParser
  #   include BaseFormatParserGetters
  #   def initialize
  #     @regex = Regex.new("^" + RE_YEAR4 + "-" + RE_MONTH_LZ + "-" + RE_DAY_LZ + "T" + RE_HOUR_24_LZ + ":" + RE_MINUTE_LZ + ":" + RE_SECOND_LZ + RE_FRAC + RE_TZ_CORRECTION + "?", Regex::Options::IGNORE_CASE)
  #     @name = "soap"
  #   end
  #   def callback (rb : ResultBuilder, match : Regex::MatchData)
  #     # match = { match, year, month, day, hour, minute, second, frac, tzCorrection }
  #     return rb.ymd(+year, month - 1, +day) &&
  #             rb.time(+hour, +minute, +second, +frac.substr(0, 3)) &&
  #             rb.zone(processTzCorrection(tzCorrection))
  #   end
  # end

  # class Wddx < BaseFormatParser
  #   include BaseFormatParserGetters
  #   def initialize
  #     @regex = Regex.new("^" + RE_YEAR4 + "-" + RE_MONTH + "-" + RE_DAY + "T" + RE_HOUR_24 + ":" + RE_MINUTE + ":" + RE_SECOND)
  #     @name = "wddx"
  #   end
  #   def callback (rb : ResultBuilder, match : Regex::MatchData)
  #     # match = { match, year, month, day, hour, minute, second }
  #     return rb.ymd(+year, month - 1, +day) && rb.time(+hour, +minute, +second, 0)
  #   end
  # end

  # class Exif < BaseFormatParser
  #   include BaseFormatParserGetters
  #   def initialize
  #     @regex = Regex.new("^" + RE_YEAR4 + ":" + RE_MONTH_LZ + ":" + RE_DAY_LZ + " " + RE_HOUR_24_LZ + ":" + RE_MINUTE_LZ + ":" + RE_SECOND_LZ, Regex::Options::IGNORE_CASE)
  #     @name = "exif"
  #   end
  #   def callback (rb : ResultBuilder, match : Regex::MatchData)
  #     # match = { match, year, month, day, hour, minute, second }
  #     return rb.ymd(+year, month - 1, +day) && rb.time(+hour, +minute, +second, 0)
  #   end
  # end

  # class XmlRpc < BaseFormatParser
  #   include BaseFormatParserGetters
  #   def initialize
  #     @regex = Regex.new("^" + RE_YEAR4 + RE_MONTH_LZ + RE_DAY_LZ + "T" + RE_HOUR_24 + ":" + RE_MINUTE_LZ + ":" + RE_SECOND_LZ)
  #     @name = "xmlrbc"
  #   end
  #   def callback (rb : ResultBuilder, match : Regex::MatchData)
  #     # match = { match, year, month, day, hour, minute, second }
  #     return rb.ymd(+year, month - 1, +day) && rb.time(+hour, +minute, +second, 0)
  #   end
  # end

  # class XmlRpcNoColon < BaseFormatParser
  #   include BaseFormatParserGetters
  #   def initialize
  #     @regex = Regex.new("^" + RE_YEAR4 + RE_MONTH_LZ + RE_DAY_LZ + "[Tt]" + RE_HOUR_24 + RE_MINUTE_LZ + RE_SECOND_LZ)
  #     @name = "xmlrbcnocolon"
  #   end
  #   def callback (rb : ResultBuilder, match : Regex::MatchData)
  #     # match = { match, year, month, day, hour, minute, second }
  #     return rb.ymd(+year, month - 1, +day) && rb.time(+hour, +minute, +second, 0)
  #   end
  # end

  # class Clf < BaseFormatParser
  #   include BaseFormatParserGetters
  #   def initialize
  #     @regex = Regex.new("^" + RE_DAY + "/(" + RE_MONTH_ABBR + ")/" + RE_YEAR4 + ":" + RE_HOUR_24_LZ + ":" + RE_MINUTE_LZ + ":" + RE_SECOND_LZ + RE_SPACE + RE_TZ_CORRECTION, Regex::Options::IGNORE_CASE)
  #     @name = "clf"
  #   end
  #   def callback (rb : ResultBuilder, match : Regex::MatchData)
  #     # match = match, day, month, year, hour, minute, second, tzCorrection
  #     return rb.ymd(+year, Iom::PHP::Strtotime.lookup_month(month), +day) &&
  #             rb.time(+hour, +minute, +second, 0) &&
  #             rb.zone(processTzCorrection(tzCorrection))
  #   end
  # end

  class Iso8601long < BaseFormatParser
    include BaseFormatParserGetters
    def initialize
      @regex = Regex.new("^t?" + RE_HOUR_24 + "[:.]" + RE_MINUTE + "[:.]" + RE_SECOND + RE_FRAC, Regex::Options::IGNORE_CASE)
      @name = "iso8601long"
    end
    def callback (rb : ResultBuilder, match : Regex::MatchData)
      hour : Int32 = match[1].try(&.to_i32) || 0
      minute : Int32 = match[2].try(&.to_i32) || 0
      second : Int32 = match[3].try(&.to_i32) || 0
      frac : Int32 = match[4][0,3].try(&.to_i32) || 0
      meridian : String = match[5]? || ""
      return rb.time(
        Iom::PHP::Strtotime.process_meridian(hour, meridian),
        minute,
        second,
        frac)
    end
  end

  class DateTextual < BaseFormatParser
    include BaseFormatParserGetters
    def initialize
      @regex = Regex.new("^" + RE_MONTH_TEXT + "[ .\\t-]*" + RE_DAY + "[,.stndrh\\t ]+" + RE_YEAR, Regex::Options::IGNORE_CASE)
      @name = "datetextual"
    end
    def callback (rb : ResultBuilder, match : Regex::MatchData)
      month : Int32 = Iom::PHP::Strtotime.lookup_month(match[1] || "") || -1
      day : Int32 = match[2].try(&.to_i32) || -1
      year : Int32 = Iom::PHP::Strtotime.process_year(match[3])

      return false if month == -1
      return false if day == -1

      return rb.ymd(year, month, day)
    end
  end

  # class PointedDate4 < BaseFormatParser
  #   include BaseFormatParserGetters
  #   def initialize
  #     @regex = Regex.new("^" + RE_DAY + "[.\\t-]" + RE_MONTH + "[.-]" + RE_YEAR4)
  #     @name = "pointeddate4"
  #   end
  #   def callback (rb : ResultBuilder, match : Regex::MatchData)
  #     day : Int32 = match[1].try(&.to_i32) || -1
  #     month : Int32 = Iom::PHP::Strtotime.lookup_month(match[1] || "") || -1
  #     year : Int32 = Iom::PHP::Strtotime.process_year(match[3])

  #     return false if month == -1
  #     return false if day == -1

  #     return rb.ymd(year, month, day)
  #   end
  # end

  # class PointedDate2 < BaseFormatParser
  #   include BaseFormatParserGetters
  #   def initialize
  #     @regex = Regex.new("^" + RE_DAY + "[.\\t]" + RE_MONTH + "\\." + RE_YEAR2)
  #     @name = "pointeddate2"
  #   end
  #   def callback (rb : ResultBuilder, match : Regex::MatchData)
  #     # match = { match, day, month, year }
  #     return rb.ymd(Iom::PHP::Strtotime.process_year(year), month - 1, +day)
  #   end
  # end

  # class TimeLong24 < BaseFormatParser
  #   include BaseFormatParserGetters
  #   def initialize
  #     @regex = Regex.new("^t?" + RE_HOUR_24 + "[:.]" + RE_MINUTE + "[:.]" + RE_SECOND)
  #     @name = "timelong24"
  #   end
  #   def callback (rb : ResultBuilder, match : Regex::MatchData)
  #     # match = { match, hour, minute, second }
  #     return rb.time(+hour, +minute, +second, 0)
  #   end
  # end

  # class DateNoColon < BaseFormatParser
  #   include BaseFormatParserGetters
  #   def initialize
  #     @regex = Regex.new("^" + RE_YEAR4 + RE_MONTH_LZ + RE_DAY_LZ)
  #     @name = "datenocolon"
  #   end
  #   def callback (rb : ResultBuilder, match : Regex::MatchData)
  #     # match = { match, year, month, day }
  #     return rb.ymd(+year, month - 1, +day)
  #   end
  # end

  # class Pgydotd < BaseFormatParser
  #   include BaseFormatParserGetters
  #   def initialize
  #     @regex = Regex.new("^" + RE_YEAR4 + "\\.?" + RE_DAY_OF_YEAR)
  #     @name = "pgydotd"
  #   end
  #   def callback (rb : ResultBuilder, match : Regex::MatchData)
  #     # match = { match, year, day }
  #     return rb.ymd(+year, 0, +day)
  #   end
  # end

  # class TimeShort24 < BaseFormatParser
  #   include BaseFormatParserGetters
  #   def initialize
  #     @regex = Regex.new("^t?" + RE_HOUR_24 + "[:.]" + RE_MINUTE, Regex::Options::IGNORE_CASE)
  #     @name = "timeshort24"
  #   end
  #   def callback (rb : ResultBuilder, match : Regex::MatchData)
  #     # match = { match, hour, minute }
  #     return rb.time(+hour, +minute, 0, 0)
  #   end
  # end

  # class Iso8601noColon < BaseFormatParser
  #   include BaseFormatParserGetters
  #   def initialize
  #     @regex = Regex.new("^t?" + RE_HOUR_24_LZ + RE_MINUTE_LZ + RE_SECOND_LZ, Regex::Options::IGNORE_CASE)
  #     @name = "iso8601nocolon"
  #   end
  #   def callback (rb : ResultBuilder, match : Regex::MatchData)
  #     # match = { match, hour, minute, second }
  #     return rb.time(+hour, +minute, +second, 0)
  #   end
  # end

  # class Iso8601dateSlash < BaseFormatParser
  #   include BaseFormatParserGetters
  #   # eventhough the trailing slash is optional in PHP
  #   # here it"s mandatory and inputs without the slash
  #   # are handled by dateslash
  #   def initialize
  #     @regex = Regex.new("^" + RE_YEAR4 + "/" + RE_MONTH_LZ + "/" + RE_DAY_LZ + "/")
  #     @name = "iso8601dateslash"
  #   end
  #   def callback (rb : ResultBuilder, match : Regex::MatchData)
  #     # match = { match, year, month, day }
  #     return rb.ymd(+year, month - 1, +day)
  #   end
  # end

  # class DateSlash < BaseFormatParser
  #   include BaseFormatParserGetters
  #   def initialize
  #     @regex = Regex.new("^" + RE_YEAR4 + "/" + RE_MONTH + "/" + RE_DAY)
  #     @name = "dateslash"
  #   end
  #   def callback (rb : ResultBuilder, match : Regex::MatchData)
  #     # match = { match, year, month, day }
  #     return rb.ymd(+year, month - 1, +day)
  #   end
  # end

  # class American < BaseFormatParser
  #   include BaseFormatParserGetters
  #   def initialize
  #     @regex = Regex.new("^" + RE_MONTH + "/" + RE_DAY + "/" + RE_YEAR)
  #     @name = "american"
  #   end
  #   def callback (rb : ResultBuilder, match : Regex::MatchData)
  #     # match = { match, month, day, year }
  #     return rb.ymd(Iom::PHP::Strtotime.process_year(year), month - 1, +day)
  #   end
  # end

  # class AmericanShort < BaseFormatParser
  #   include BaseFormatParserGetters
  #   def initialize
  #     @regex = Regex.new("^" + RE_MONTH + "/" + RE_DAY)
  #     @name = "americanshort"
  #   end
  #   def callback (rb : ResultBuilder, match : Regex::MatchData)
  #     # match = { match, month, day }
  #     return rb.ymd(rb.y, month - 1, +day)
  #   end
  # end

  # class GnuDateShortOrIso8601date2 < BaseFormatParser
  #   include BaseFormatParserGetters
  #   # iso8601date2 is comp subset of gnudateshort
  #   def initialize
  #     @regex = Regex.new("^" + RE_YEAR + "-" + RE_MONTH + "-" + RE_DAY)
  #     @name = "gnudateshort | iso8601date2"
  #   end
  #   def callback (rb : ResultBuilder, match : Regex::MatchData)
  #     # match = { match, year, month, day }
  #     return rb.ymd(Iom::PHP::Strtotime.process_year(year), month - 1, +day)
  #   end
  # end

  # class Iso8601date4 < BaseFormatParser
  #   include BaseFormatParserGetters
  #   def initialize
  #     @regex = Regex.new("^" + RE_YEAR4_WITH_SIGN + "-" + RE_MONTH_LZ + "-" + RE_DAY_LZ)
  #     @name = "iso8601date4"
  #   end
  #   def callback (rb : ResultBuilder, match : Regex::MatchData)
  #     # match, year, month, day
  #     return rb.ymd(+year, month - 1, +day)
  #   end
  # end

  # class GnuNoColon < BaseFormatParser
  #   include BaseFormatParserGetters
  #   def initialize
  #     @regex = Regex.new("^t?" + RE_HOUR_24_LZ + RE_MINUTE_LZ, Regex::Options::IGNORE_CASE)
  #     @name = "gnunocolon"
  #   end
  #   def callback (rb : ResultBuilder, match : Regex::MatchData)
  #     # match, hour, minute
  #     # rb rule is a special case
  #     # if time was already set once by any preceding rule, it sets the captured value as year
  #     case rb.times
  #     when 0
  #       return rb.time(+hour, +minute, 0, rb.f)
  #     when 1
  #       rb.y = hour * 100 + +minute
  #       rb.times += 1

  #       return true
  #     else
  #       return false
  #     end
  #   end
  # end

  # class GnuDateShorter < BaseFormatParser
  #   include BaseFormatParserGetters
  #   def initialize
  #     @regex = Regex.new("^" + RE_YEAR4 + "-" + RE_MONTH)
  #     @name = "gnudateshorter"
  #   end
  #   def callback (rb : ResultBuilder, match : Regex::MatchData)
  #     # match, year, month
  #     return rb.ymd(+year, month - 1, 1)
  #   end
  # end

  # class PgTextReverse < BaseFormatParser
  #   include BaseFormatParserGetters
  #   # note: allowed years are from 32-9999
  #   # years below 32 should be treated as days in datefull
  #   def initialize
  #     @regex = Regex.new("^" + "(\\d{3,4}|[4-9]\\d|3[2-9])-(" + RE_MONTH_ABBR + ")-" + RE_DAY_LZ, Regex::Options::IGNORE_CASE)
  #     @name = "pgtextreverse"
  #   end
  #   def callback (rb : ResultBuilder, match : Regex::MatchData)
  #     # match, year, month, day
  #     return rb.ymd(Iom::PHP::Strtotime.process_year(year), Iom::PHP::Strtotime.lookup_month(month), +day)
  #   end
  # end

  # class DateFull < BaseFormatParser
  #   include BaseFormatParserGetters
  #   def initialize
  #     @regex = Regex.new("^" + RE_DAY + "[ \\t.-]*" + RE_MONTH_TEXT + "[ \\t.-]*" + RE_YEAR, Regex::Options::IGNORE_CASE)
  #     @name = "datefull"
  #   end
  #   def callback (rb : ResultBuilder, match : Regex::MatchData)
  #     # match, day, month, year
  #     return rb.ymd(Iom::PHP::Strtotime.process_year(year), Iom::PHP::Strtotime.lookup_month(month), +day)
  #   end
  # end

  # class DateNoDay < BaseFormatParser
  #   include BaseFormatParserGetters
  #   def initialize
  #     @regex = Regex.new("^" + RE_MONTH_TEXT + "[ .\\t-]*" + RE_YEAR4, Regex::Options::IGNORE_CASE)
  #     @name = "datenoday"
  #   end
  #   def callback (rb : ResultBuilder, match : Regex::MatchData)
  #     # match, month, year
  #     return rb.ymd(+year, Iom::PHP::Strtotime.lookup_month(month), 1)
  #   end
  # end

  # class DateNoDayRev < BaseFormatParser
  #   include BaseFormatParserGetters
  #   def initialize
  #     @regex = Regex.new("^" + RE_YEAR4 + "[ .\\t-]*" + RE_MONTH_TEXT, Regex::Options::IGNORE_CASE)
  #     @name = "datenodayrev"
  #   end
  #   def callback (rb : ResultBuilder, match : Regex::MatchData)
  #     # match, year, month
  #     return rb.ymd(+year, Iom::PHP::Strtotime.lookup_month(month), 1)
  #   end
  # end

  # class PgTextShort < BaseFormatParser
  #   include BaseFormatParserGetters
  #   def initialize
  #     @regex = Regex.new("^(" + RE_MONTH_ABBR + ")-" + RE_DAY_LZ + "-" + RE_YEAR, Regex::Options::IGNORE_CASE)
  #     @name = "pgtextshort"
  #   end
  #   def callback (rb : ResultBuilder, match : Regex::MatchData)
  #     # match, month, day, year
  #     return rb.ymd(Iom::PHP::Strtotime.process_year(year), Iom::PHP::Strtotime.lookup_month(month), +day)
  #   end
  # end

  # class DateNoYear < BaseFormatParser
  #   include BaseFormatParserGetters
  #   def initialize
  #     @regex = Regex.new("^" + RE_DATE_NO_YEAR, Regex::Options::IGNORE_CASE)
  #     @name = "datenoyear"
  #   end
  #   def callback (rb : ResultBuilder, match : Regex::MatchData)
  #     # match, month, day
  #     return rb.ymd(rb.y, Iom::PHP::Strtotime.lookup_month(month), +day)
  #   end
  # end

  # class DateNoYearRev < BaseFormatParser
  #   include BaseFormatParserGetters
  #   def initialize
  #     @regex = Regex.new("^" + RE_DAY + "[ .\\t-]*" + RE_MONTH_TEXT, Regex::Options::IGNORE_CASE)
  #     @name = "datenoyearrev"
  #   end
  #   def callback (rb : ResultBuilder, match : Regex::MatchData)
  #     # match, day, month
  #     return rb.ymd(rb.y, Iom::PHP::Strtotime.lookup_month(month), +day)
  #   end
  # end

  # class IsoWeekDay < BaseFormatParser
  #   include BaseFormatParserGetters
  #   def initialize
  #     @regex = Regex.new("^" + RE_YEAR4 + "-?W" + RE_WEEK_OF_YEAR + "(?:-?([0-7]))?")
  #     @name = "isoweekday | isoweek"
  #   end
  #   def callback (rb : ResultBuilder, match : Regex::MatchData)
  #     # match, year, week, day
  #     day = match.day
  #     day = day ? +day : 1

  #     if !rb.ymd(+year, 0, 1)
  #       return false
  #     end

  #     # get day of week for Jan 1st
  #     day_of_week = Time.utc(rb.y, rb.m, rb.d).day_of_week

  #     # and use the day to figure out the offset for day 1 of week 1
  #     day_of_week = 0 - (day_of_week > 4 ? day_of_week - 7 : day_of_week)

  #     rb.rd += day_of_week + ((week - 1) * 7) + day
  #   end
  # end

  # class RelativeText < BaseFormatParser
  #   include BaseFormatParserGetters
  #   def initialize
  #     @regex = Regex.new("^(" + RE_REL_TEXT_NUM + "|" + RE_REL_TEXT_TEXT + ")" + RE_SPACE + "(" + RE_REL_TEXT_UNIT + ")", Regex::Options::IGNORE_CASE)
  #     @name = "relativetext"
  #   end
  #   def callback (rb : ResultBuilder, match : Regex::MatchData)
  #     # match, rel_value, rel_unit
  #     # todo: implement handling of "rb time-unit"
  #     # eslint-disable-next-line no-unused-vars
  #     rl = lookup_relative(rel_value)
  #     amount = rl.amount
  #     behavior = rl.behavior

  #     case rel_unit.downcase
  #     when "sec", "secs", "second", "seconds"
  #       rb.rs += amount
  #     when "min", "mins", "minute", "minutes"
  #       rb.ri += amount
  #     when "hour", "hours"
  #       rb.rh += amount
  #     when "day", "days"
  #       rb.rd += amount
  #     when "fortnight", "fortnights", "forthnight", "forthnights"
  #       rb.rd += amount * 14
  #     when "week", "weeks"
  #       rb.rd += amount * 7
  #     when "month", "months"
  #       rb.rm += amount
  #     when "year", "years"
  #       rb.ry += amount
  #     when "mon", "monday", "tue", "tuesday", "wed", "wednesday", "thu", "thursday", "fri", "friday", "sat", "saturday", "sun", "sunday"
  #       rb.resetTime()
  #       rb.weekday = lookup_weekday(rel_unit, 7)
  #       rb.weekday_behavior = 1
  #       rb.rd += (amount > 0 ? amount - 1 : amount) * 7
  #     when "weekday", "weekdays"
  #       # todo
  #     end
  #   end
  # end

  # class Relative < BaseFormatParser
  #   include BaseFormatParserGetters
  #   def initialize
  #     @regex = Regex.new("^([+-]*)[ \\t]*(\\d+)" + RE_SPACE_OPT + "(" + RE_REL_TEXT_UNIT + "|week)", Regex::Options::IGNORE_CASE)
  #     @name = "relative"
  #   end
  #   def callback (rb : ResultBuilder, match : Regex::MatchData)
  #     # match, signs, rel_value, rel_unit
  #     minuses = signs.gsub(/[^-]/, "").size

  #     amount = +rel_value * Math.pow(-1, minuses)

  #     case rel_unit.downcase
  #     when "sec", "secs", "second", "seconds"
  #       rb.rs += amount
  #     when "min", "mins", "minute", "minutes"
  #       rb.ri += amount
  #     when "hour", "hours"
  #       rb.rh += amount
  #     when "day", "days"
  #       rb.rd += amount
  #     when "fortnight", "fortnights", "forthnight", "forthnights"
  #       rb.rd += amount * 14
  #     when "week", "weeks"
  #       rb.rd += amount * 7
  #     when "month", "months"
  #       rb.rm += amount
  #     when "year" ,"years"
  #       rb.ry += amount
  #     when "mon", "monday", "tue", "tuesday", "wed", "wednesday", "thu", "thursday", "fri", "friday", "sat", "saturday", "sun", "sunday"
  #       rb.resetTime()
  #       rb.weekday = lookup_weekday(rel_unit, 7)
  #       rb.weekday_behavior = 1
  #       rb.rd += (amount > 0 ? amount - 1 : amount) * 7
  #     when "weekday", "weekdays"
  #       # todo
  #     end
  #   end
  # end

  # class DayText < BaseFormatParser
  #   include BaseFormatParserGetters
  #   def initialize
  #     @regex = Regex.new("^(" + RE_DAY_TEXT + ")", Regex::Options::IGNORE_CASE)
  #     @name = "daytext"
  #   end
  #   def callback (rb : ResultBuilder, match : Regex::MatchData)
  #     # match, dayText
  #     rb.resetTime()
  #     rb.weekday = lookup_weekday(dayText, 0)

  #     if rb.weekday_behavior != 2
  #       rb.weekday_behavior = 1
  #     end
  #   end
  # end

  # class RelativeTextWeek < BaseFormatParser
  #   include BaseFormatParserGetters
  #   def initialize
  #     @regex = Regex.new("^(" + RE_REL_TEXT_TEXT + ")" + RE_SPACE + "week", Regex::Options::IGNORE_CASE)
  #     @name = "relativetextweek"
  #   end
  #   def callback (rb : ResultBuilder, match : Regex::MatchData)
  #     # match, relText
  #     rb.weekday_behavior = 2

  #     case relText.downcase
  #     when "rb"
  #       rb.rd += 0
  #     when "next"
  #       rb.rd += 7
  #     when "last", "previous"
  #       rb.rd -= 7
  #     end

  #     if isNil(rb.weekday)
  #       rb.weekday = 1
  #     end
  #   end
  # end

  # class MonthFullOrMonthAbbr < BaseFormatParser
  #   include BaseFormatParserGetters
  #   def initialize
  #     @regex = Regex.new("^(" + RE_MONTH_FULL + "|" + RE_MONTH_ABBR + ")", Regex::Options::IGNORE_CASE)
  #     @name = "monthfull | monthabbr"
  #   end
  #   def callback (rb : ResultBuilder, match : Regex::MatchData)
  #     # match, month
  #     return rb.ymd(rb.y, Iom::PHP::Strtotime.lookup_month(month), rb.d)
  #   end
  # end

  # class TzCorrection < BaseFormatParser
  #   include BaseFormatParserGetters
  #   def initialize
  #     @regex = Regex.new("^" + RE_TZ_CORRECTION, Regex::Options::IGNORE_CASE)
  #     @name = "tzcorrection"
  #   end
  #   def callback (rb : ResultBuilder, match : Regex::MatchData)
  #     return rb.zone(processTzCorrection(tzCorrection))
  #   end
  # end

  # class Ago < BaseFormatParser
  #   include BaseFormatParserGetters
  #   def initialize
  #     @regex = /^ago/i
  #     @name = "ago"
  #   end
  #   def callback (rb : ResultBuilder, match : Regex::MatchData)
  #     rb.ry = -rb.ry
  #     rb.rm = -rb.rm
  #     rb.rd = -rb.rd
  #     rb.rh = -rb.rh
  #     rb.ri = -rb.ri
  #     rb.rs = -rb.rs
  #     rb.rf = -rb.rf
  #   end
  # end

  # class Year4 < BaseFormatParser
  #   include BaseFormatParserGetters
  #   def initialize
  #     @regex = Regex.new("^" + RE_YEAR4)
  #     @name = "year4"
  #   end
  #   def callback (rb : ResultBuilder, match : Regex::MatchData)
  #     # match, year
  #     rb.y = +year
  #     return true
  #   end
  # end

  # class Whitespace < BaseFormatParser
  #   include BaseFormatParserGetters
  #   def initialize
  #     @regex = /^[ .,\t]+/
  #     @name = "whitespac"
  #   end
  #   def callback (rb : ResultBuilder, match : Regex::MatchData)
  #     # do nothing
  #   end
  # end

  # class DateShortWithTimeLong < BaseFormatParser
  #   include BaseFormatParserGetters
  #   def initialize
  #     @regex = Regex.new("^" + RE_DATE_NO_YEAR + "t?" + RE_HOUR_24 + "[:.]" + RE_MINUTE + "[:.]" + RE_SECOND, Regex::Options::IGNORE_CASE)
  #     @name = "dateshortwithtimelong"
  #   end
  #   def callback (rb : ResultBuilder, match : Regex::MatchData)
  #     # match, month, day, hour, minute, second
  #     return rb.ymd(rb.y, Iom::PHP::Strtotime.lookup_month(month), +day) && rb.time(+hour, +minute, +second, 0)
  #   end
  # end

  # class DateShortWithTimeLong12 < BaseFormatParser
  #   include BaseFormatParserGetters
  #   def initialize
  #     @regex = Regex.new("^" + RE_DATE_NO_YEAR + RE_HOUR_12 + "[:.]" + RE_MINUTE + "[:.]" + RE_SECOND_LZ + RE_SPACE_OPT + RE_MERIDIAN, Regex::Options::IGNORE_CASE)
  #     @name = "dateshortwithtimelong12"
  #   end
  #   def callback (rb : ResultBuilder, match : Regex::MatchData)
  #     # match, month, day, hour, minute, second, meridian
  #     return rb.ymd(rb.y, Iom::PHP::Strtotime.lookup_month(month), +day) && rb.time(Iom::PHP::Strtotime.process_meridian(+hour, meridian), +minute, +second, 0)
  #   end
  # end

  # class DateShortWithTimeShort < BaseFormatParser
  #   include BaseFormatParserGetters
  #   def initialize
  #     @regex = Regex.new("^" + RE_DATE_NO_YEAR + "t?" + RE_HOUR_24 + "[:.]" + RE_MINUTE, Regex::Options::IGNORE_CASE)
  #     @name = "dateshortwithtimeshort"
  #   end
  #   def callback (rb : ResultBuilder, match : Regex::MatchData)
  #     # match, month, day, hour, minute
  #     return rb.ymd(rb.y, Iom::PHP::Strtotime.lookup_month(month), +day) && rb.time(+hour, +minute, 0, 0)
  #   end
  # end

  # class DateShortWithTimeShort12 < BaseFormatParser
  #   include BaseFormatParserGetters
  #   def initialize
  #     @regex = Regex.new("^" + RE_DATE_NO_YEAR + RE_HOUR_12 + "[:.]" + RE_MINUTE_LZ + RE_SPACE_OPT + RE_MERIDIAN, Regex::Options::IGNORE_CASE)
  #     @name = "dateshortwithtimeshort12"
  #   end
  #   def callback (rb : ResultBuilder, match : Regex::MatchData)
  #     # match, month, day, hour, minute, meridian
  #     return rb.ymd(rb.y, Iom::PHP::Strtotime.lookup_month(month), +day) && rb.time(Iom::PHP::Strtotime.process_meridian(+hour, meridian), +minute, 0, 0)
  #   end
  # end
end
