# strtotime

An in-progress implementation of PHP's strtotime function

Note: see [src/Strtotime/formatter_bag.cr](src/Strtotime/formatter_bag.cr) to see which algorithmns are enabled.
Note: see [src/Strtotime/formatter_parsers.cr](src/Strtotime/formatter_parsers.cr) to see which algorithmns can be finished.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     strtotime:
       github: iomcr/php-strtotime
   ```

2. Run `shards install`

## Usage

```crystal
require "strtotime"

value : Time = Iom::PHP::Strtotime.strtotime("yesterday")
# 2020-06-13 00:00:00 UTC

now : Time = Time.parse_rfc3339("2005-10-18T11:00:00Z")
value : Time = Iom::PHP::Strtotime.strtotime("yesterday", now)
# 2005-10-17 00:00:00 UTC

value : Int64 = Iom::PHP::Strtotime.strtotime("now", now = 1129633200)
# 1129633200

value : Int64 = Iom::PHP::Strtotime.strtotime("@1129633200").to_unix
# 1129633200
```

## TODO anything else supported by PHP's native strtotime function
```php

>>> \Carbon\Carbon::createFromTimestampUTC(strtotime('dec 12 2004 4pm', 1129633200))->toRfc3339String()
=> "2004-12-12T16:00:00+00:00"
>>> \Carbon\Carbon::createFromTimestampUTC(strtotime('+14 hours'))->toRfc3339String()
=> "2020-06-14T14:52:54+00:00"
>>> \Carbon\Carbon::createFromTimestampUTC(strtotime('now'))->toRfc3339String()
=> "2020-06-14T00:54:53+00:00"
>>> \Carbon\Carbon::createFromTimestampUTC(strtotime('30 minutes'))->toRfc3339String()
=> "2020-06-14T01:24:59+00:00"
```

## Development

TODO:
* Implement all algorithmns (approx 25% implemented)
* Ensure combinations work
* Even more tests.

## Contributing

1. Fork it (<https://github.com/iomcr/php-strtotime/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [IOM](https://github.com/iomcr) - creator and maintainer
