module Iom::PHP::Strtotime::Formats::Parts
  reSpace : String = "[ \\t]+"
  reSpaceOpt : String = "[ \\t]*"
  reMeridian : String = "(?:([ap])\\.?m\\.?([\\t ]|$))"
  reHour24 : String = "(2[0-4]|[01]?[0-9])"
  reHour24lz : String = "([01][0-9]|2[0-4])"
  reHour12 : String = "(0?[1-9]|1[0-2])"
  reMinute : String = "([0-5]?[0-9])"
  reMinutelz : String = "([0-5][0-9])"
  reSecond : String = "(60|[0-5]?[0-9])"
  reSecondlz : String = "(60|[0-5][0-9])"
  reFrac : String = "(?:\\.([0-9]+))"

  reDayfull : String = "sunday|monday|tuesday|wednesday|thursday|friday|saturday"
  reDayabbr : String = "sun|mon|tue|wed|thu|fri|sat"
  reDaytext : String = reDayfull + "|" + reDayabbr + "|weekdays?"

  reReltextnumber : String = "first|second|third|fourth|fifth|sixth|seventh|eighth?|ninth|tenth|eleventh|twelfth"
  reReltexttext : String = "next|last|previous|this"
  reReltextunit : String = "(?:second|sec|minute|min|hour|day|fortnight|forthnight|month|year)s?|weeks|" + reDaytext

  reYear : String = "([0-9]{1,4})"
  reYear2 : String = "([0-9]{2})"
  reYear4 : String = "([0-9]{4})"
  reYear4withSign : String = "([+-]?[0-9]{4})"
  reMonth : String = "(1[0-2]|0?[0-9])"
  reMonthlz : String = "(0[0-9]|1[0-2])"
  reDay : String = "(?:(3[01]|[0-2]?[0-9])(?:st|nd|rd|th)?)"
  reDaylz : String = "(0[0-9]|[1-2][0-9]|3[01])"

  reMonthFull : String = "january|february|march|april|may|june|july|august|september|october|november|december"
  reMonthAbbr : String = "jan|feb|mar|apr|may|jun|jul|aug|sept?|oct|nov|dec"
  reMonthroman : String = "i[vx]|vi{0,3}|xi{0,2}|i{1,3}"
  reMonthText : String = "(" + reMonthFull + "|" + reMonthAbbr + "|" + reMonthroman + ")"

  reTzCorrection : String = "((?:GMT)?([+-])" + reHour24 + ":?" + reMinute + "?)"
  reDayOfYear : String = "(00[1-9]|0[1-9][0-9]|[12][0-9][0-9]|3[0-5][0-9]|36[0-6])"
  reWeekOfYear : String = "(0[1-9]|[1-4][0-9]|5[0-3])"

  reDateNoYear : String = reMonthText + "[ .\\t-]*" + reDay + "[,.stndrh\\t ]*"
end
