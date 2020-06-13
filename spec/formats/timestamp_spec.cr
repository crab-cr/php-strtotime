require "../spec_helper"

# private NOW = Time.unix(1129633200)
private NOW = Time.parse_rfc3339("2005-10-18T11:00:00Z")

# php artisan tinker: \Carbon\Carbon::createFromTimestampUTC(strtotime('tomorrow', 1129633200))->toRfc3339String()

describe "Iom::PHP::Strtotime::Timestamp" do
  it "should accept 'timestamp' 1" do
    Iom::PHP::Strtotime.strtotime("@1129633200", NOW).should eq Time.parse_rfc3339("2005-10-18T11:00:00Z")
  end
  it "should accept 'timestamp' 2" do
    Iom::PHP::Strtotime.strtotime("@1115633200", NOW).should eq Time.unix(1115633200)
  end
end
