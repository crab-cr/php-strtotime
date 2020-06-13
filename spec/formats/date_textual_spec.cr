require "../spec_helper"

# private NOW = Time.unix(1129633200)
private NOW = Time.parse_rfc3339("2005-10-18T11:00:00Z")

# php artisan tinker: \Carbon\Carbon::createFromTimestampUTC(strtotime('tomorrow', 1129633200))->toRfc3339String()

describe "Iom::PHP::Strtotime::DateTextual" do
  it "should accept 'december' 1" do
    Iom::PHP::Strtotime.strtotime("december 12rd 2004", NOW).should eq Time.parse_rfc3339("2004-12-12T11:00:00+00:00")
    Iom::PHP::Strtotime.strtotime("december 12th 2004", NOW).should eq Time.parse_rfc3339("2004-12-12T11:00:00+00:00")
    Iom::PHP::Strtotime.strtotime("december 12 2004", NOW).should eq Time.parse_rfc3339("2004-12-12T11:00:00+00:00")
  end
end
