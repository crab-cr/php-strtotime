require "./spec_helper"

# private NOW = Time.unix(1129633200)
private NOW = Time.parse_rfc3339("2005-10-18T11:00:00Z")

# php artisan tinker: \Carbon\Carbon::createFromTimestampUTC(strtotime('yesterday', 1129633200))->toRfc3339String()

describe "Iom::PHP::Strtotime" do
  it "should allow now as Int64" do
    Iom::PHP::Strtotime.strtotime("now", 1129633200_i64).should eq 1129633200_i64
  end

  # it "should pass example 1" do
  #   Iom::PHP::Strtotime.strtotime("+1 day", NOW).should eq Time.unix(1129719600)
  # end
  # it "should pass example 2" do
  #   Iom::PHP::Strtotime.strtotime("+1 week 2 days 4 hours 2 seconds", NOW).should eq Time.unix(1130425202)
  # end
  # it "should pass example 3" do
  #   Iom::PHP::Strtotime.strtotime("last month", NOW).should eq Time.unix(1127041200)
  # end
  # it "should pass example 4" do
  #   Iom::PHP::Strtotime.strtotime("2009-05-04 08:30:00 GMT", NOW).should eq Time.unix(1241425800)
  # end
  # it "should pass example 5" do
  #   Iom::PHP::Strtotime.strtotime("2009-05-04 08:30:00+00", NOW).should eq Time.unix(1241425800)
  # end
  # it "should pass example 6" do
  #   Iom::PHP::Strtotime.strtotime("2009-05-04 08:30:00+02:00", NOW).should eq Time.unix(1241418600)
  # end
  # it "should pass example 7" do
  #   Iom::PHP::Strtotime.strtotime("2009-05-04T08:30:00Z", NOW).should eq Time.unix(1241425800)
  # end
  # it "should pass example 8" do
  #   Iom::PHP::Strtotime.strtotime("dec 12 2004 04pm", NOW).should eq Time.parse_rfc3339("2004-12-12T16:00:00+00:00")
  # end
end
