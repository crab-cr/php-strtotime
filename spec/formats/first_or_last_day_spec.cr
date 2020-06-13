require "../spec_helper"

# private NOW = Time.unix(1129633200)
private NOW = Time.parse_rfc3339("2005-10-18T11:00:00Z")

# php artisan tinker: \Carbon\Carbon::createFromTimestampUTC(strtotime('tomorrow', 1129633200))->toRfc3339String()

describe "Iom::PHP::Strtotime::FirstOrLastDay" do
  it "should accept 'first day of'" do
    Iom::PHP::Strtotime.strtotime("first day of", NOW).should eq Time.parse_rfc3339("2005-10-01T11:00:00+00:00")
  end
  it "should accept 'last day of'" do
    Iom::PHP::Strtotime.strtotime("last day of", NOW).should eq Time.parse_rfc3339("2005-10-31T11:00:00+00:00")
  end
end
