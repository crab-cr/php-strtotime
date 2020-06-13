module Iom::PHP::Strtotime
  struct Result
    # date
    property y : Int32
    property m : Int32
    property d : Int32
    # time
    property h : Int32
    property i : Int32
    property s : Int32
    property f : Int32
  
    # # relative shifts
    # property ry : Int32 = 0_i32
    # property rm : Int32 = 0_i32
    # property rd : Int32 = 0_i32
    # property rh : Int32 = 0_i32
    # property ri : Int32 = 0_i32
    # property rs : Int32 = 0_i32
    # property rf : Int32 = 0_i32
  
    # weekday related shifts
    # property weekday : Int32? = nil
    # property weekday_behavior : Int32 = 0_i32
  
    # first or last day of month
    # 0 none, 1 first, -1 last
    # property firstOrLastDayOfMonth : Int32 = 0_i32
  
    # timezone correction in minutes
    property z : Int64? = nil
  
    # counters
    property dates : Int32 = 0_i32
    property times : Int32 = 0_i32
    property zones : Int32 = 0_i32

    property builder : ResultBuilder
    property relative_to : Time
    property value : Time? = nil
  
    def initialize (@builder : ResultBuilder, @relative_to : Time)
      if builder.dates && !builder.times
        builder.h = builder.i = builder.s = builder.f = 0
      end
  
      # fill holes
      @y = (y = builder.y).nil? ? @relative_to.year : y
      @m = (m = builder.m).nil? ? @relative_to.month : m
      @d = (d = builder.d).nil? ? @relative_to.day : d
      @h = (h = builder.h).nil? ? @relative_to.hour : h
      @i = (i = builder.i).nil? ? @relative_to.minute : i
      @s = (s = builder.s).nil? ? @relative_to.second : s
      @f = (f = builder.f).nil? ? @relative_to.millisecond : f
    
      # adjust special early
      case @builder.firstOrLastDayOfMonth
      when 1
        @d = 1
      when -1
        @d = 28
        # @m += 1
      else
        # pass
      end
  
      unless (weekday = @builder.weekday).nil?
        # date = new Date(@relative_to.getTime())
        date = Time.utc(
          year: @y,
          month: @m,
          day: @d,
          hour: @h,
          minute: @i,
          second: @s,
          nanosecond: @f * 1000000)
    
        # JS 0-6, 0=Sunday
        # CR 1-7, 7=Sunday https://crystal-lang.org/api/0.35.0/Time/DayOfWeek.html
        dow = date.day_of_week()
  
        if @builder.weekday_behavior == 2
          # To make "this week" work, where the current day of week is a "sunday"
          if dow == 0 && weekday != 0
            weekday = -6
          end 
          # To make "sunday this week" work, where the current day of week is not a "sunday"
          if weekday == 0 && (dow != 0 && dow != 7)
            weekday = 7
          end 
            @d -= dow.value
            @d += weekday
        else
          diff = weekday - dow.value
  
          # some PHP magic
          if (@builder.rd < 0 && diff < 0) || (@builder.rd >= 0 && diff <= -@builder.weekday_behavior)
            diff += 7
          end
          if weekday >= 0
            @d += diff
          else
            @d -= (7 - (weekday.abs - dow.value))
          end
          # this property isn't used after this point, so no reason to empty it
          # @builder.weekday = nil
        end     
      end
  
      # adjust relative
      @y += @builder.ry
      @m += @builder.rm
      @d += @builder.rd
  
      @h += @builder.rh
      @i += @builder.ri
      @s += @builder.rs
      @f += @builder.rf

      # these properties aren't used after this point, so no reason to empty them
      # @builder.ry = @builder.rm = @builder.rd = 0
      # @builder.rh = @builder.ri = @builder.rs = @builder.rf = 0
  
      # result = new Date(@relative_to.getTime())
      # result = @relative_to.clone
      # since Date constructor treats years <= 99 as 1900+
      # it can't be used, thus this weird way
      # dateObj.setFullYear(yearValue[, monthValue[, dateValue]])
      # result.setFullYear(self.y, self.m, self.d)
      # dateObj.setHours(hoursValue[, minutesValue[, secondsValue[, msValue]]])
      # result.setHours(self.h, self.i, self.s, self.f)
      # .utc(year : Int32, month : Int32, day : Int32, hour : Int32 = 0, minute : Int32 = 0, second : Int32 = 0, *, nanosecond : Int32 = 0) : Time


      # JavaScript date.getTimezoneOffset() -> minutes
      # Crystal time.offset -> seconds
      location = @relative_to.location
      # adjust timezone
      unless (z = @builder.z).nil?
        unless (relative_to.offset / 60) == z
          location = Time::Location.fixed(z * 60_i32)
        end
      end

      result = Time.local(
        year: @y,
        month: @m,
        day: @d,
        hour: @h,
        minute: @i,
        second: @s,
        nanosecond: @f * 1000000,
        location: location)
  
      # note: this is done twice in PHP
      # early when processing special relatives
      # and late
      # todo: check if the logic can be reduced
      # to just one time action
      case @builder.firstOrLastDayOfMonth
      when 1
        bom = result.at_beginning_of_month
        result = Time.local(
          year: result.year,
          month: result.month,
          day: bom.day,
          hour: result.hour,
          minute: result.minute,
          second: result.second,
          nanosecond: result.nanosecond,
          location: location)
      when -1
        eom = result.at_end_of_month
        result = Time.local(
          year: result.year,
          month: result.month,
          day: eom.day,
          hour: result.hour,
          minute: result.minute,
          second: result.second,
          nanosecond: result.nanosecond,
          location: location)
      else
        # pass
      end
    
      @value = result
    end
  end

end
