require "../spec_helper"

# private NOW = Time.unix(1129633200)
private NOW = Time.parse_rfc3339("2005-10-18T11:00:00Z")

# php artisan tinker: \Carbon\Carbon::createFromTimestampUTC(strtotime('tomorrow', 1129633200))->toRfc3339String()

describe "Iom::PHP::Strtotime::BackOrFrontOf" do
  it "should accept 'back of'" do
    Iom::PHP::Strtotime.strtotime("back of 10pm", NOW).should eq Time.parse_rfc3339("2005-10-18T22:15:00+00:00")
  end
  it "should accept 'front of'" do
    Iom::PHP::Strtotime.strtotime("front of 10pm", NOW).should eq Time.parse_rfc3339("2005-10-18T21:45:00+00:00")
  end
end
