require "../spec_helper"

# private NOW = Time.unix(1129633200)
private NOW = Time.parse_rfc3339("2005-10-18T11:00:00Z")

# php artisan tinker: \Carbon\Carbon::createFromTimestampUTC(strtotime('now', 1129633200))->toRfc3339String()

describe "Iom::PHP::Strtotime::Now" do
  it "should accept 'now'" do
    Iom::PHP::Strtotime.strtotime("now", NOW).should eq Time.parse_rfc3339("2005-10-18T11:00:00Z")
  end
end
