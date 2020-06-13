require "../spec_helper"

# private NOW = Time.unix(1129633200)
private NOW = Time.parse_rfc3339("2005-10-18T11:00:00Z")

# php artisan tinker: \Carbon\Carbon::createFromTimestampUTC(strtotime('tomorrow', 1129633200))->toRfc3339String()

describe "Iom::PHP::Strtotime::Iso8601long" do
  it "should accept 'Iso8601long' 1" do
    Iom::PHP::Strtotime.strtotime("T11:00:00.0000000", NOW).should eq Time.parse_rfc3339("2005-10-18T11:00:00Z")
    # PHP actually does not accecpt 8 fractional seconds digits
    Iom::PHP::Strtotime.strtotime("T11:00:00.00000000", NOW).should eq Time.parse_rfc3339("2005-10-18T11:00:00Z")
  end
end
