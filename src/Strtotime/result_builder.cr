module Iom::PHP::Strtotime
  class ResultBuilder
    # date
    property y : Int32? = nil
    property m : Int32? = nil
    property d : Int32? = nil
    # time
    property h : Int32? = nil
    property i : Int32? = nil
    property s : Int32? = nil
    property f : Int32? = nil
  
    # relative shifts
    property ry : Int32 = 0_i32
    property rm : Int32 = 0_i32
    property rd : Int32 = 0_i32
    property rh : Int32 = 0_i32
    property ri : Int32 = 0_i32
    property rs : Int32 = 0_i32
    property rf : Int32 = 0_i32
  
    # weekday related shifts
    property weekday : Int32? = nil
    property weekday_behavior : Int32 = 0_i32
  
    # first or last day of month
    # 0 none, 1 first, -1 last
    property firstOrLastDayOfMonth : Int32 = 0_i32
  
    # timezone correction in minutes
    property z : Int32? = nil
  
    # counters
    property dates : Int32 = 0_i32
    property times : Int32 = 0_i32
    property zones : Int32 = 0_i32
  
    # helper functions
    def ymd (y : Int32, m : Int32, d : Int32) : Bool
      if @dates > 0
        return false
      end
  
      @dates += 1
      @y = y
      @m = m
      @d = d
      return true
    end
  
    def time (h, i, s, f) : Bool
      if @times > 0
        return false
      end
  
      @times += 1
      @h = h
      @i = i
      @s = s
      @f = f
  
      return true
    end
  
    def resetTime
      @h = 0
      @i = 0
      @s = 0
      @f = 0
      @times = 0
    end
  
    def zone (minutes : Int32) : Bool
      if @zones <= 1
        @zones += 1
        @z = minutes
        return true
      end
  
      return false
    end

    def reset_as (time : Time)
      # date
      @y = time.year
      @m = time.month
      @d = time.day
      # time
      @h = time.hour
      @i = time.minute
      @s = time.second
      @f = time.millisecond
    
      # relative shifts
      @ry = 0_i32
      @rm = 0_i32
      @rd = 0_i32
      @rh = 0_i32
      @ri = 0_i32
      @rs = 0_i32
      @rf = 0_i32
    
      # weekday related shifts
      @weekday = nil
      @weekday_behavior = 0_i32
    
      # first or last day of month
      # 0 none, 1 first, -1 last
      @firstOrLastDayOfMonth = 0_i32
    
      # timezone correction in minutes
      @z = nil
    
      # counters
      @dates = 0_i32
      @times = 0_i32
      @zones = 0_i32
    end
  end
end
