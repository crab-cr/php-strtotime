
# the rule order is important
# if multiple rules match, the longest match wins
# if multiple rules match the same string, the first match wins
private RULES = Iom::PHP::Strtotime::FormatterBag.new

module Iom::PHP::Strtotime
  def self.strtotime (str : String, now : Time = Time.utc) : Time?
    # now was an int in JS
    # if (now == nil) {
    #   now = Math.floor(Date.now() / 1000)
    # }
    builder = ResultBuilder.new()

    while str.size > 0
      longest_match : Regex::MatchData? = nil
      final_rule : Iom::PHP::Strtotime::Formats::BaseFormatParser? = nil

      RULES.list.each do |format|
        match : Regex::MatchData? = str.match(format.regex)
        unless match.nil?
          if longest_match.nil?
            longest_match = match
            final_rule = format
          elsif (match[0]?.try(&.size) || 0) > (longest_match[0]?.try(&.size) || 0)
            longest_match = match
            final_rule = format
          end
        end
      end

      if final_rule.nil?
        return nil
      elsif final_rule.callback(builder, longest_match) == false
        return nil
      end

      str = str[longest_match.not_nil![0].size, str.size]
      final_rule = nil
      longest_match = nil
    end

    # puts builder
    # result.toDate(now)
    Result.new(builder, now).value
  end
end
