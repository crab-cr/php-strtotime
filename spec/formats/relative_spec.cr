require "../spec_helper"

# private NOW = Time.unix(1129633200)
private NOW = Time.parse_rfc3339("2005-10-18T11:00:00Z")

# php artisan tinker: \Carbon\Carbon::createFromTimestampUTC(strtotime('tomorrow', 1129633200))->toRfc3339String()

describe "Iom::PHP::Strtotime::Relative" do
  it "should accept 'Relative' 1" do
    # @todo
    # Iom::PHP::Strtotime.strtotime("+12 minutes", NOW).should eq Time.parse_rfc3339("2005-10-18T11:00:00Z")
  end
end
