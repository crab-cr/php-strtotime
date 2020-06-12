require "./formats_parts"

module Iom::PHP::Strtotime::Formats

  struct Yesterday
    @@regex : Regex = /^yesterday/i
    @@name: String = "yesterday"
    def callback (rp : ResultProto)
      rp.rd -= 1
      return rp.resetTime()
    end
  end

  struct Now
    @@regex : Regex = /^now/i
    @@name: String = "no"
    def callback (rp : ResultProto)
      # do nothing
    end
  end

  struct Noon
    @@regex : Regex = /^noon/i
    @@name: String = "noon"
    def callback (rp : ResultProto)
      return rp.resetTime() && rp.time(12, 0, 0, 0)
    end
  end

  struct MidnightOrToday
    @@regex : Regex = /^(midnight|today)/i
    @@name: String = "midnight | today"
    def callback (rp : ResultProto)
      return rp.resetTime()
    end
  end

  struct Tomorrow
    @@regex : Regex = /^tomorrow/i
    @@name: String = "tomorrow"
    def callback (rp : ResultProto)
      rp.rd += 1
      return rp.resetTime()
    end
  end

  struct Timestamp
    @@regex : Regex = /^@(-?\d+)/i
    @@name: String = "timestamp"
    def callback (rp : ResultProto, match, timestamp : Time)
      rp.rs += timestamp.to_unix
      rp.y = 1970
      rp.m = 0
      rp.d = 1
      rp.dates = 0

      return rp.resetTime() && rp.zone(0)
    end
  end

  struct FirstOrLastDay
    @@regex : Regex = /^(first|last) day of/i
    @@name: String = "firstdayof | lastdayof"
    def callback (rp : ResultProto, match, day)
      if day.downcase == "first"
        rp.firstOrLastDayOfMonth = 1
      else
        rp.firstOrLastDayOfMonth = -1
      end
    end
  end

  struct BackOrFrontOf
    include Iom::PHP::Strtotime::Formats::Parts

    @@regex : Regex = Regex.new("^(back|front) of " + reHour24 + reSpaceOpt + reMeridian + "?", "i")
    @@name: String = "backof | frontof"
    def callback (rp : ResultProto, match, side, hours, meridian)
      back = side.downcase == "back"
      hour = +hours
      minute = 15

      if !back
        hour -= 1
        minute = 45
      end

      hour = processMeridian(hour, meridian)

      return rp.resetTime() && rp.time(hour, minute, 0, 0)
    end
  end

  struct WeekdayOf
    @@regex : Regex = Regex.new("^(" + reReltextnumber + "|" + reReltexttext + ")" + reSpace + "(" + reDayfull + "|" + reDayabbr + ")" + reSpace + "of", "i")
    @@name: String = "weekdayo"
    def callback (rp : ResultProto)
      # todo
    end
  end

  struct Mssqltime
    @@regex : Regex = Regex.new("^" + reHour12 + ":" + reMinutelz + ":" + reSecondlz + "[:.]([0-9]+)" + reMeridian, "i")
    @@name: String = "mssqltime"
    def callback (rp : ResultProto, match, hour, minute, second, frac, meridian)
      return rp.time(processMeridian(+hour, meridian), +minute, +second, +frac.substr(0, 3))
    end
  end

  struct TimeLong12
    @@regex : Regex = Regex.new("^" + reHour12 + "[:.]" + reMinute + "[:.]" + reSecondlz + reSpaceOpt + reMeridian, "i")
    @@name: String = "timelong12"
    def callback (rp : ResultProto, match, hour, minute, second, meridian)
      return rp.time(processMeridian(+hour, meridian), +minute, +second, 0)
    end
  end

  struct TimeShort12
    @@regex : Regex = Regex.new("^" + reHour12 + "[:.]" + reMinutelz + reSpaceOpt + reMeridian, "i")
    @@name: String = "timeshort12"
    def callback (rp : ResultProto, match, hour, minute, meridian)
      return rp.time(processMeridian(+hour, meridian), +minute, 0, 0)
    end
  end

  struct TimeTiny12
    @@regex : Regex = Regex.new("^" + reHour12 + reSpaceOpt + reMeridian, "i")
    @@name: String = "timetiny12"
    def callback (rp : ResultProto, match, hour, meridian)
      return rp.time(processMeridian(+hour, meridian), 0, 0, 0)
    end
  end

  struct Soap
    @@regex : Regex = Regex.new("^" + reYear4 + "-" + reMonthlz + "-" + reDaylz + "T" + reHour24lz + ":" + reMinutelz + ":" + reSecondlz + reFrac + reTzCorrection + "?", "i")
    @@name: String = "soap"
    def callback (rp : ResultProto, match, year, month, day, hour, minute, second, frac, tzCorrection)
      return rp.ymd(+year, month - 1, +day) &&
              rp.time(+hour, +minute, +second, +frac.substr(0, 3)) &&
              rp.zone(processTzCorrection(tzCorrection))
    end
  end

  struct Wddx
    @@regex : Regex = Regex.new("^" + reYear4 + "-" + reMonth + "-" + reDay + "T" + reHour24 + ":" + reMinute + ":" + reSecond)
    @@name: String = "wddx"
    def callback (rp : ResultProto, match, year, month, day, hour, minute, second)
      return rp.ymd(+year, month - 1, +day) && rp.time(+hour, +minute, +second, 0)
    end
  end

  struct Exif
    @@regex : Regex = Regex.new("^" + reYear4 + ":" + reMonthlz + ":" + reDaylz + " " + reHour24lz + ":" + reMinutelz + ":" + reSecondlz, "i")
    @@name: String = "exif"
    def callback (rp : ResultProto, match, year, month, day, hour, minute, second)
      return rp.ymd(+year, month - 1, +day) && rp.time(+hour, +minute, +second, 0)
    end
  end

  struct XmlRpc
    @@regex : Regex = Regex.new("^" + reYear4 + reMonthlz + reDaylz + "T" + reHour24 + ":" + reMinutelz + ":" + reSecondlz)
    @@name: String = "xmlrpc"
    def callback (rp : ResultProto, match, year, month, day, hour, minute, second)
      return rp.ymd(+year, month - 1, +day) && rp.time(+hour, +minute, +second, 0)
    end
  end

  struct XmlRpcNoColon
    @@regex : Regex = Regex.new("^" + reYear4 + reMonthlz + reDaylz + "[Tt]" + reHour24 + reMinutelz + reSecondlz)
    @@name: String = "xmlrpcnocolon"
    def callback (rp : ResultProto, match, year, month, day, hour, minute, second)
      return rp.ymd(+year, month - 1, +day) && rp.time(+hour, +minute, +second, 0)
    end
  end

  struct Clf
    @@regex : Regex = Regex.new("^" + reDay + "/(" + reMonthAbbr + ")/" + reYear4 + ":" + reHour24lz + ":" + reMinutelz + ":" + reSecondlz + reSpace + reTzCorrection, "i")
    @@name: String = "clf"
    def callback (rp : ResultProto, match, day, month, year, hour, minute, second, tzCorrection)
      return rp.ymd(+year, lookupMonth(month), +day) &&
              rp.time(+hour, +minute, +second, 0) &&
              rp.zone(processTzCorrection(tzCorrection))
    end
  end

  struct Iso8601long
    @@regex : Regex = Regex.new("^t?" + reHour24 + "[:.]" + reMinute + "[:.]" + reSecond + reFrac, "i")
    @@name: String = "iso8601long"
    def callback (rp : ResultProto, match, hour, minute, second, frac)
      return rp.time(+hour, +minute, +second, +frac.substr(0, 3))
    end
  end

  struct DateTextual
    @@regex : Regex = Regex.new("^" + reMonthText + "[ .\\t-]*" + reDay + "[,.stndrh\\t ]+" + reYear, "i")
    @@name: String = "datetextual"
    def callback (rp : ResultProto, match, month, day, year)
      return rp.ymd(processYear(year), lookupMonth(month), +day)
    end
  end

  struct PointedDate4
    @@regex : Regex = Regex.new("^" + reDay + "[.\\t-]" + reMonth + "[.-]" + reYear4)
    @@name: String = "pointeddate4"
    def callback (rp : ResultProto, match, day, month, year)
      return rp.ymd(+year, month - 1, +day)
    end
  end

  struct PointedDate2
    @@regex : Regex = Regex.new("^" + reDay + "[.\\t]" + reMonth + "\\." + reYear2)
    @@name: String = "pointeddate2"
    def callback (rp : ResultProto, match, day, month, year)
      return rp.ymd(processYear(year), month - 1, +day)
    end
  end

  struct TimeLong24
    @@regex : Regex = Regex.new("^t?" + reHour24 + "[:.]" + reMinute + "[:.]" + reSecond)
    @@name: String = "timelong24"
    def callback (rp : ResultProto, match, hour, minute, second)
      return rp.time(+hour, +minute, +second, 0)
    end
  end

  struct DateNoColon
    @@regex : Regex = Regex.new("^" + reYear4 + reMonthlz + reDaylz)
    @@name: String = "datenocolon"
    def callback (rp : ResultProto, match, year, month, day)
      return rp.ymd(+year, month - 1, +day)
    end
  end

  struct Pgydotd
    @@regex : Regex = Regex.new("^" + reYear4 + "\\.?" + reDayOfYear)
    @@name: String = "pgydotd"
    def callback (rp : ResultProto, match, year, day)
      return rp.ymd(+year, 0, +day)
    end
  end

  struct TimeShort24
    @@regex : Regex = Regex.new("^t?" + reHour24 + "[:.]" + reMinute, "i")
    @@name: String = "timeshort24"
    def callback (rp : ResultProto, match, hour, minute)
      return rp.time(+hour, +minute, 0, 0)
    end
  end

  struct Iso8601noColon
    @@regex : Regex = Regex.new("^t?" + reHour24lz + reMinutelz + reSecondlz, "i")
    @@name: String = "iso8601nocolon"
    def callback (rp : ResultProto, match, hour, minute, second)
      return rp.time(+hour, +minute, +second, 0)
    end
  end

  struct Iso8601dateSlash
    # eventhough the trailing slash is optional in PHP
    # here it"s mandatory and inputs without the slash
    # are handled by dateslash
    @@regex : Regex = Regex.new("^" + reYear4 + "/" + reMonthlz + "/" + reDaylz + "/")
    @@name: String = "iso8601dateslash"
    def callback (rp : ResultProto, match, year, month, day)
      return rp.ymd(+year, month - 1, +day)
    end
  end

  struct DateSlash
    @@regex : Regex = Regex.new("^" + reYear4 + "/" + reMonth + "/" + reDay)
    @@name: String = "dateslash"
    def callback (rp : ResultProto, match, year, month, day)
      return rp.ymd(+year, month - 1, +day)
    end
  end

  struct American
    @@regex : Regex = Regex.new("^" + reMonth + "/" + reDay + "/" + reYear)
    @@name: String = "american"
    def callback (rp : ResultProto, match, month, day, year)
      return rp.ymd(processYear(year), month - 1, +day)
    end
  end

  struct AmericanShort
    @@regex : Regex = Regex.new("^" + reMonth + "/" + reDay)
    @@name: String = "americanshort"
    def callback (rp : ResultProto, match, month, day)
      return rp.ymd(rp.y, month - 1, +day)
    end
  end

  struct GnuDateShortOrIso8601date2
    # iso8601date2 is comp subset of gnudateshort
    @@regex : Regex = Regex.new("^" + reYear + "-" + reMonth + "-" + reDay)
    @@name: String = "gnudateshort | iso8601date2"
    def callback (rp : ResultProto, match, year, month, day)
      return rp.ymd(processYear(year), month - 1, +day)
    end
  end

  struct Iso8601date4
    @@regex : Regex = Regex.new("^" + reYear4withSign + "-" + reMonthlz + "-" + reDaylz)
    @@name: String = "iso8601date4"
    def callback (rp : ResultProto, match, year, month, day)
      return rp.ymd(+year, month - 1, +day)
    end
  end

  struct GnuNoColon
    @@regex : Regex = Regex.new("^t?" + reHour24lz + reMinutelz, "i")
    @@name: String = "gnunocolon"
    def callback (rp : ResultProto, match, hour, minute)
      # rp rule is a special case
      # if time was already set once by any preceding rule, it sets the captured value as year
      case rp.times
      when 0
        return rp.time(+hour, +minute, 0, rp.f)
      when 1
        rp.y = hour * 100 + +minute
        rp.times += 1

        return true
      else
        return false
      end
    end
  end

  struct GnuDateShorter
    @@regex : Regex = Regex.new("^" + reYear4 + "-" + reMonth)
    @@name: String = "gnudateshorter"
    def callback (rp : ResultProto, match, year, month)
      return rp.ymd(+year, month - 1, 1)
    end
  end

  struct PgTextReverse
    # note: allowed years are from 32-9999
    # years below 32 should be treated as days in datefull
    @@regex : Regex = Regex.new("^" + "(\\d{3,4}|[4-9]\\d|3[2-9])-(" + reMonthAbbr + ")-" + reDaylz, "i")
    @@name: String = "pgtextreverse"
    def callback (rp : ResultProto, match, year, month, day)
      return rp.ymd(processYear(year), lookupMonth(month), +day)
    end
  end

  struct DateFull
    @@regex : Regex = Regex.new("^" + reDay + "[ \\t.-]*" + reMonthText + "[ \\t.-]*" + reYear, "i")
    @@name: String = "datefull"
    def callback (rp : ResultProto, match, day, month, year)
      return rp.ymd(processYear(year), lookupMonth(month), +day)
    end
  end

  struct DateNoDay
    @@regex : Regex = Regex.new("^" + reMonthText + "[ .\\t-]*" + reYear4, "i")
    @@name: String = "datenoday"
    def callback (rp : ResultProto, match, month, year)
      return rp.ymd(+year, lookupMonth(month), 1)
    end
  end

  struct DateNoDayRev
    @@regex : Regex = Regex.new("^" + reYear4 + "[ .\\t-]*" + reMonthText, "i")
    @@name: String = "datenodayrev"
    def callback (rp : ResultProto, match, year, month)
      return rp.ymd(+year, lookupMonth(month), 1)
    end
  end

  struct PgTextShort
    @@regex : Regex = Regex.new("^(" + reMonthAbbr + ")-" + reDaylz + "-" + reYear, "i")
    @@name: String = "pgtextshort"
    def callback (rp : ResultProto, match, month, day, year)
      return rp.ymd(processYear(year), lookupMonth(month), +day)
    end
  end

  struct DateNoYear
    @@regex : Regex = Regex.new("^" + reDateNoYear, "i")
    @@name: String = "datenoyear"
    def callback (rp : ResultProto, match, month, day)
      return rp.ymd(rp.y, lookupMonth(month), +day)
    end
  end

  struct DateNoYearRev
    @@regex : Regex = Regex.new("^" + reDay + "[ .\\t-]*" + reMonthText, "i")
    @@name: String = "datenoyearrev"
    def callback (rp : ResultProto, match, day, month)
      return rp.ymd(rp.y, lookupMonth(month), +day)
    end
  end

  struct IsoWeekDay
    @@regex : Regex = Regex.new("^" + reYear4 + "-?W" + reWeekOfYear + "(?:-?([0-7]))?")
    @@name: String = "isoweekday | isoweek"
    def callback (rp : ResultProto, match, year, week, day)
      day = day ? +day : 1

      if !rp.ymd(+year, 0, 1)
        return false
      end

      # get day of week for Jan 1st
      day_of_week = Time.utc(rp.y, rp.m, rp.d).day_of_week

      # and use the day to figure out the offset for day 1 of week 1
      day_of_week = 0 - (day_of_week > 4 ? day_of_week - 7 : day_of_week)

      rp.rd += day_of_week + ((week - 1) * 7) + day
    end
  end

  struct RelativeText
    @@regex : Regex = Regex.new("^(" + reReltextnumber + "|" + reReltexttext + ")" + reSpace + "(" + reReltextunit + ")", "i")
    @@name: String = "relativetext"
    def callback (rp : ResultProto, match, relValue, relUnit)
      # todo: implement handling of "rp time-unit"
      # eslint-disable-next-line no-unused-vars
      rl = lookup_relative(relValue)
      amount = rl.amount
      behavior = rl.behavior

      case relUnit.downcase
      when "sec", "secs", "second", "seconds"
        rp.rs += amount
      when "min", "mins", "minute", "minutes"
        rp.ri += amount
      when "hour", "hours"
        rp.rh += amount
      when "day", "days"
        rp.rd += amount
      when "fortnight", "fortnights", "forthnight", "forthnights"
        rp.rd += amount * 14
      when "week", "weeks"
        rp.rd += amount * 7
      when "month", "months"
        rp.rm += amount
      when "year", "years"
        rp.ry += amount
      when "mon", "monday", "tue", "tuesday", "wed", "wednesday", "thu", "thursday", "fri", "friday", "sat", "saturday", "sun", "sunday"
        rp.resetTime()
        rp.weekday = lookupWeekday(relUnit, 7)
        rp.weekdayBehavior = 1
        rp.rd += (amount > 0 ? amount - 1 : amount) * 7
      when "weekday", "weekdays"
        # todo
      end
    end
  end

  struct Relative
    @@regex : Regex = Regex.new("^([+-]*)[ \\t]*(\\d+)" + reSpaceOpt + "(" + reReltextunit + "|week)", "i")
    @@name: String = "relative"
    def callback (rp : ResultProto, match, signs, relValue, relUnit)
      const minuses = signs.gsub(/[^-]/, "").length

      amount = +relValue * Math.pow(-1, minuses)

      case relUnit.downcase
      when "sec", "secs", "second", "seconds"
        rp.rs += amount
      when "min", "mins", "minute", "minutes"
        rp.ri += amount
      when "hour", "hours"
        rp.rh += amount
      when "day", "days"
        rp.rd += amount
      when "fortnight", "fortnights", "forthnight", "forthnights"
        rp.rd += amount * 14
      when "week", "weeks"
        rp.rd += amount * 7
      when "month", "months"
        rp.rm += amount
      when "year" ,"years"
        rp.ry += amount
      when "mon", "monday", "tue", "tuesday", "wed", "wednesday", "thu", "thursday", "fri", "friday", "sat", "saturday", "sun", "sunday"
        rp.resetTime()
        rp.weekday = lookupWeekday(relUnit, 7)
        rp.weekdayBehavior = 1
        rp.rd += (amount > 0 ? amount - 1 : amount) * 7
      when "weekday", "weekdays"
        # todo
      end
    end
  end

  struct DayText
    @@regex : Regex = Regex.new("^(" + reDaytext + ")", "i")
    @@name: String = "daytext"
    def callback (rp : ResultProto, match, dayText)
      rp.resetTime()
      rp.weekday = lookupWeekday(dayText, 0)

      if rp.weekdayBehavior != 2
        rp.weekdayBehavior = 1
      end
    end
  end

  struct RelativeTextWeek
    @@regex : Regex = Regex.new("^(" + reReltexttext + ")" + reSpace + "week", "i")
    @@name: String = "relativetextweek"
    def callback (rp : ResultProto, match, relText)
      rp.weekdayBehavior = 2

      case relText.downcase
      when "rp"
        rp.rd += 0
      when "next"
        rp.rd += 7
      when "last", "previous"
        rp.rd -= 7
      end

      if isNil(rp.weekday)
        rp.weekday = 1
      end
    end
  end

  struct MonthFullOrMonthAbbr
    @@regex : Regex = Regex.new("^(" + reMonthFull + "|" + reMonthAbbr + ")", "i")
    @@name: String = "monthfull | monthabbr"
    def callback (rp : ResultProto, match, month)
      return rp.ymd(rp.y, lookupMonth(month), rp.d)
    end
  end

  struct TzCorrection
    @@regex : Regex = Regex.new("^" + reTzCorrection, "i")
    @@name: String = "tzcorrection"
    def callback (rp : ResultPrototzCorrection)
      return rp.zone(processTzCorrection(tzCorrection))
    end
  end

  struct Ago
    @@regex : Regex = /^ago/i
    @@name: String = "ago"
    def callback (rp : ResultProto)
      rp.ry = -rp.ry
      rp.rm = -rp.rm
      rp.rd = -rp.rd
      rp.rh = -rp.rh
      rp.ri = -rp.ri
      rp.rs = -rp.rs
      rp.rf = -rp.rf
    end
  end

  struct Year4
    @@regex : Regex = Regex.new("^" + reYear4)
    @@name: String = "year4"
    def callback (rp : ResultProto, match, year)
      rp.y = +year
      return true
    end
  end

  struct Whitespace
    @@regex : Regex = /^[ .,\t]+/
    @@name: String = "whitespac"
    def callback (rp : ResultProto)
      # do nothing
    end
  end

  struct DateShortWithTimeLong
    @@regex : Regex = Regex.new("^" + reDateNoYear + "t?" + reHour24 + "[:.]" + reMinute + "[:.]" + reSecond, "i")
    @@name: String = "dateshortwithtimelong"
    def callback (rp : ResultProto, match, month, day, hour, minute, second)
      return rp.ymd(rp.y, lookupMonth(month), +day) && rp.time(+hour, +minute, +second, 0)
    end
  end

  struct DateShortWithTimeLong12
    @@regex : Regex = Regex.new("^" + reDateNoYear + reHour12 + "[:.]" + reMinute + "[:.]" + reSecondlz + reSpaceOpt + reMeridian, "i")
    @@name: String = "dateshortwithtimelong12"
    def callback (rp : ResultProto, match, month, day, hour, minute, second, meridian)
      return rp.ymd(rp.y, lookupMonth(month), +day) && rp.time(processMeridian(+hour, meridian), +minute, +second, 0)
    end
  end

  struct DateShortWithTimeShort
    @@regex : Regex = Regex.new("^" + reDateNoYear + "t?" + reHour24 + "[:.]" + reMinute, "i")
    @@name: String = "dateshortwithtimeshort"
    def callback (rp : ResultProto, match, month, day, hour, minute)
      return rp.ymd(rp.y, lookupMonth(month), +day) && rp.time(+hour, +minute, 0, 0)
    end
  end

  struct DateShortWithTimeShort12
    @@regex : Regex = Regex.new("^" + reDateNoYear + reHour12 + "[:.]" + reMinutelz + reSpaceOpt + reMeridian, "i")
    @@name: String = "dateshortwithtimeshort12"
    def callback (rp : ResultProto, match, month, day, hour, minute, meridian)
      return rp.ymd(rp.y, lookupMonth(month), +day) && rp.time(processMeridian(+hour, meridian), +minute, 0, 0)
    end
  end
end
