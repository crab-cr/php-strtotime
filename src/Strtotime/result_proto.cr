module Iom::PHP::Strtotime
  struct ResultProto
    # date
    y : Int16? = nil
    m : Int16? = nil
    d : Int16? = nil
    # time
    h : Int16? = nil
    i : Int16? = nil
    s : Int16? = nil
    f : Int16? = nil
  
    # relative shifts
    ry : Int16 = 0_i16
    rm : Int16 = 0_i16
    rd : Int16 = 0_i16
    rh : Int16 = 0_i16
    ri : Int16 = 0_i16
    rs : Int16 = 0_i16
    rf : Int16 = 0_i16
  
    # weekday related shifts
    weekday : Int16? = nil
    weekdayBehavior : Int16 = 0_i16
  
    # first or last day of month
    # 0 none, 1 first, -1 last
    firstOrLastDayOfMonth : Int16 = 0_i16
  
    # timezone correction in minutes
    z : Int64? = nil
  
    # counters
    dates : Int16 = 0_i16
    times : Int16 = 0_i16
    zones : Int16 = 0_i16
  
    # helper functions
    def ymd (y : Int16, m : Int16, d : Int16) : Boolean
      if self.dates > 0
        return false
      end
  
      self.dates += 1
      self.y = y
      self.m = m
      self.d = d
      return true
    end
  
    def time (h, i, s, f) : Boolean
      if self.times > 0
        return false
      end
  
      self.times += 1
      self.h = h
      self.i = i
      self.s = s
      self.f = f
  
      return true
    end
  
    def resetTime
      self.h = 0
      self.i = 0
      self.s = 0
      self.f = 0
      self.times = 0
    end
  
    def zone (minutes : Int16) : Boolean
      if self.zones <= 1
        self.zones += 1
        self.z = minutes
        return true
      end
  
      return false
    end
  
    def toDate (relativeTo)
      if self.dates && !self.times
        self.h = self.i = self.s = self.f = 0
      end
  
      # fill holes
      if isNil(self.y)
        self.y = relativeTo.getFullYear()
      end
  
      if isNil(self.m)
        self.m = relativeTo.getMonth()
      end
  
      if isNil(self.d)
        self.d = relativeTo.getDate()
      end
  
      if isNil(self.h)
        self.h = relativeTo.getHours()
      end
  
      if isNil(self.i)
        self.i = relativeTo.getMinutes()
      end
  
      if isNil(self.s)
        self.s = relativeTo.getSeconds()
      end
  
      if isNil(self.f)
        self.f = relativeTo.getMilliseconds()
      end
  
      # adjust special early
      case self.firstOrLastDayOfMonth
      when 1
        self.d = 1
      when -1
        self.d = 0
        self.m += 1
      end
  
      unless self.weekday.nil?
        # date = new Date(relativeTo.getTime())
        date = relativeTo.clone
        date.setFullYear(self.y, self.m, self.d)
        date.setHours(self.h, self.i, self.s, self.f)
  
        dow = date.getDay()
  
        if self.weekdayBehavior === 2
          # To make "self week" work, where the current day of week is a "sunday"
          if dow === 0 && self.weekday != 0
            self.weekday = -6
          end 
          # To make "sunday self week" work, where the current day of week is not a "sunday"
          if self.weekday === 0 && dow != 0
            self.weekday = 7
          end 
          self.d -= dow
          self.d += self.weekday
        else
          diff = self.weekday - dow
  
          # some PHP magic
          if (self.rd < 0 && diff < 0) || (self.rd >= 0 && diff <= -self.weekdayBehavior)
            diff += 7
          end 
          if self.weekday >= 0
            self.d += diff
          else
            self.d -= (7 - (Math.abs(self.weekday) - dow))
          end 
          self.weekday = Nil
        end     
      end
  
      # adjust relative
      self.y += self.ry
      self.m += self.rm
      self.d += self.rd
  
      self.h += self.rh
      self.i += self.ri
      self.s += self.rs
      self.f += self.rf
  
      self.ry = self.rm = self.rd = 0
      self.rh = self.ri = self.rs = self.rf = 0
  
      # result = new Date(relativeTo.getTime())
      result = relativeTo.clone
      # since Date constructor treats years <= 99 as 1900+
      # it can't be used, thus self weird way
      result.setFullYear(self.y, self.m, self.d)
      result.setHours(self.h, self.i, self.s, self.f)
  
      # note: self is done twice in PHP
      # early when processing special relatives
      # and late
      # todo: check if the logic can be reduced
      # to just one time action
      case self.firstOrLastDayOfMonth
      when 1
        result.setDate(1)
      when -1
        result.setMonth(result.getMonth() + 1, 0)
      end
  
      # adjust timezone
      if !self.z.nil? && result.getTimezoneOffset() != self.z
        result.setUTCFullYear(
          result.getFullYear(),
          result.getMonth(),
          result.getDate())
  
        result.setUTCHours(
          result.getHours(),
          result.getMinutes() + self.z,
          result.getSeconds(),
          result.getMilliseconds())
      end
  
      return result
    end
  end

end
