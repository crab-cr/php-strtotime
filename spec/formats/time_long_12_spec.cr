require "../spec_helper"

# private NOW = Time.unix(1129633200)
private NOW = Time.parse_rfc3339("2005-10-18T11:00:00Z")

# php artisan tinker: \Carbon\Carbon::createFromTimestampUTC(strtotime('tomorrow', 1129633200))->toRfc3339String()

describe "Iom::PHP::Strtotime::TimeLong12" do
  it "should accept '10:00:00 PM' 1" do
    Iom::PHP::Strtotime.strtotime("10:00:00 PM", NOW).should eq Time.parse_rfc3339("2005-10-18T10:00:00+00:00")
  end
end
