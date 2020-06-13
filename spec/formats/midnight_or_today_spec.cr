require "../spec_helper"

# private NOW = Time.unix(1129633200)
private NOW = Time.parse_rfc3339("2005-10-18T11:00:00Z")

# php artisan tinker: \Carbon\Carbon::createFromTimestampUTC(strtotime('midnight', 1129633200))->toRfc3339String()

describe "Iom::PHP::Strtotime::MidnightOrToday" do
  it "should accept 'midnight'" do
    Iom::PHP::Strtotime.strtotime("midnight", NOW).should eq Time.parse_rfc3339("2005-10-18T00:00:00+00:00")
  end
  it "should accept 'today'" do
    Iom::PHP::Strtotime.strtotime("today", NOW).should eq Time.parse_rfc3339("2005-10-18T00:00:00+00:00")
  end
end
