require "../spec_helper"

# private NOW = Time.unix(1129633200)
private NOW = Time.parse_rfc3339("2005-10-18T11:00:00Z")

# php artisan tinker: \Carbon\Carbon::createFromTimestampUTC(strtotime('tomorrow', 1129633200))->toRfc3339String()

describe "Iom::PHP::Strtotime::Tomorrow" do
  it "should accept 'tomorrow'" do
    Iom::PHP::Strtotime.strtotime("tomorrow", NOW).should eq Time.parse_rfc3339("2005-10-19T00:00:00+00:00")
  end
end
