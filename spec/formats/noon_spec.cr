require "../spec_helper"

# private NOW = Time.unix(1129633200)
private NOW = Time.parse_rfc3339("2005-10-18T11:00:00Z")

# php artisan tinker: \Carbon\Carbon::createFromTimestampUTC(strtotime('noon', 1129633200))->toRfc3339String()

describe "Iom::PHP::Strtotime::Noon" do
  it "should accept 'noon'" do
    Iom::PHP::Strtotime.strtotime("noon", NOW).should eq Time.parse_rfc3339("2005-10-18T12:00:00+00:00")
  end
end
