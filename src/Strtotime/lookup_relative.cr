module Iom::PHP::Strtotime
  relative_numbers_map : Hash(String, Int16) = {
    "last" => -1_i16,
    "previous" => -1_i16,
    "this" => 0_i16,
    "first" => 1_i16,
    "next" => 1_i16,
    "second" => 2_i16,
    "third" => 3_i16,
    "fourth" => 4_i16,
    "fifth" => 5_i16,
    "sixth" => 6_i16,
    "seventh" => 7_i16,
    "eight" => 8_i16,
    "eighth" => 8_i16,
    "ninth" => 9_i16,
    "tenth" => 10_i16,
    "eleventh" => 11_i16,
    "twelfth" => 12_i16,
  }

  relative_behavior_map : Hash(String, Int16) = {
    "this" => 1_i16,
  }

  def self.lookup_relative (reltext : String) : Relative
    reltext = reltext.downcase
    Relative.new(
      amount: relative_numbers_map[reltext]?,
      behavior: relative_behavior_map[reltext]? || 0)
  end

  struct Relative
    property amount : Int16?
    property behavior : Int16

    def initialize(@amount, @behavior)
    end
  end
end
