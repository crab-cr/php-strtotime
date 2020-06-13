# require "./spec_helper"

# # private NOW = Time.unix(1129633200)
# private NOW = Time.parse_rfc3339("2005-10-18T11:00:00Z")

# # php artisan tinker: \Carbon\Carbon::createFromTimestampUTC(strtotime('yesterday', 1129633200))->toRfc3339String()

# describe "Iom::PHP::Strtotime" do
#   it "should accept 'yesterday'", focus: true do
#     Iom::PHP::Strtotime.strtotime("yesterday", NOW).should eq Time.parse_rfc3339("2005-10-17T00:00:00Z")
#   end
#   it "should pass example 1" do
#     Iom::PHP::Strtotime.strtotime("+1 day", NOW).should eq Time.unix(1129719600)
#   end
#   it "should pass example 2" do
#     Iom::PHP::Strtotime.strtotime("+1 week 2 days 4 hours 2 seconds", NOW).should eq Time.unix(1130425202)
#   end
#   it "should pass example 3" do
#     Iom::PHP::Strtotime.strtotime("last month", NOW).should eq Time.unix(1127041200)
#   end
#   it "should pass example 4" do
#     Iom::PHP::Strtotime.strtotime("2009-05-04 08:30:00 GMT", NOW).should eq Time.unix(1241425800)
#   end
#   it "should pass example 5" do
#     Iom::PHP::Strtotime.strtotime("2009-05-04 08:30:00+00", NOW).should eq Time.unix(1241425800)
#   end
#   it "should pass example 6" do
#     Iom::PHP::Strtotime.strtotime("2009-05-04 08:30:00+02:00", NOW).should eq Time.unix(1241418600)
#   end
#   it "should pass example 7" do
#     Iom::PHP::Strtotime.strtotime("2009-05-04T08:30:00Z", NOW).should eq Time.unix(1241425800)
#   end
# end
