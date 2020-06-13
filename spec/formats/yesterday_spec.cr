require "../spec_helper"

# private NOW = Time.unix(1129633200)
private NOW = Time.parse_rfc3339("2005-10-18T11:00:00Z")

# php artisan tinker: \Carbon\Carbon::createFromTimestampUTC(strtotime('yesterday', 1129633200))->toRfc3339String()

describe "Iom::PHP::Strtotime" do
  it "should accept 'yesterday'" do
    Iom::PHP::Strtotime.strtotime("yesterday", NOW).should eq Time.parse_rfc3339("2005-10-17T00:00:00Z")
  end
end
