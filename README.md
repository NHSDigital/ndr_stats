# NdrStats

Provides pain-free setup of stats collecting to Ruby/Rails projects.

## Assumed Architecture

This library currently sends UDP packets to the configured receiver using the statsd format (with tagging addition).

The conventional way we set this up is as follows:

```
+-------------+   UDP   +----------------------------+
| Ruby client |  ---->  | Prometheus Statsd Exporter |
+-------------+         +----------------------------+
                                     |
                                     | scraped by
                                     V
  +---------+            +-----------------------+
  | Grafana |    <----   | Central Prometheus DB |
  +---------+            +-----------------------+
```

## Setup

### Ruby

First, set up the library to point at a Statsd receiver:

```ruby
NdrStats.configure(host: 'localhost', port: 9125)
```

### Rails

When used in a Rails application, you can store configuration in `config/stats.yml`.

```yaml
---
host: localhost
port: 9125
```

It's additionally possible to specify `system` and `stack`, which will be automatically added as tags on all stats.
If the host application's enclosing module responds to the `flavour` or `stack` methods, these will be used if not otherwise specified.

## Usage

Basic usage is as follows:

```ruby
# increment counts of things:
NdrStats.count(:issues)
NdrStats.count(:issues, 3)

# time things:
NdrStats.time(:paint_drying) { paint.dry! }
NdrStats.timing(:web_request, 100) # milliseconds

# set counts of things:
NdrStats.gauge(:population, 8_000_000_000)
```

All methods additionally accept tags, sent using the DataDog format extension:

```ruby
NdrStats.count(:issues, +1, type: :closed)
NdrStats.count(:issues, -1, type: :open)
```

### Pings

You can register background pings (for process status checks) using `NdrStats.ping`,
by supplying tags. These will also use any default tags you have configured.

Metrics:
* `ndr_stats_initial_ping` is incremented once, initially
* `ndr_stats_ping` is then incremented periodically, according to the frequency
* `ndr_stats_final_ping` is incremented once on exit, if it's possible to do so.

```ruby
# basic tagged ping:
NdrStats.ping(type: 'webapp')

# supply additional tags:
NdrStats.ping(type: 'daemon', name: 'batch importer')

# set a custom frequency (defaults to every minute):
NdrStats.ping(type: 'sloth', every: 3.hours)
```

See `NdrStats::Ping` for more details.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git co


## Code of Conduct

Everyone interacting in the NdrStats project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the `CODE_OF_CONDUCT.md`.
