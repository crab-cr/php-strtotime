require "./spec_helper"

private NOW = 1129633200

describe "Iom::PHP::Strtotime" do
  it "should pass example 1" do
    Iom::PHP.strtotime("+1 day", NOW).should eq 1129719600
  end
  it "should pass example 2" do
    Iom::PHP.strtotime("+1 week 2 days 4 hours 2 seconds", NOW).should eq 1130425202
  end
  it "should pass example 3" do
    Iom::PHP.strtotime("last month", NOW).should eq 1127041200
  end
  it "should pass example 4" do
    Iom::PHP.strtotime("2009-05-04 08:30:00 GMT", NOW).should eq 1241425800
  end
  it "should pass example 5" do
    Iom::PHP.strtotime("2009-05-04 08:30:00+00", NOW).should eq 1241425800
  end
  it "should pass example 6" do
    Iom::PHP.strtotime("2009-05-04 08:30:00+02:00", NOW).should eq 1241418600
  end
  it "should pass example 7" do
    Iom::PHP.strtotime("2009-05-04T08:30:00Z", NOW).should eq 1241425800
  end
end
