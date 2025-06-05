# RuboCop Ipepe

[![Gem Version](https://badge.fury.io/rb/rubocop-ipepe.svg)](https://rubygems.org/gems/rubocop-ipepe)
![CI](https://github.com/ipepe-oss/rubocop-ipepe/workflows/CI/badge.svg)

[RuboCop](https://github.com/rubocop/rubocop).

## Installation

Just install the `rubocop-ipepe` gem

```bash
gem install rubocop-ipepe
```

or if you use bundler put this in your `Gemfile`

```ruby
gem 'rubocop-ipepe', require: false
```

## Usage

You need to tell RuboCop to load the Ipepe extension. There are three
ways to do this:

### RuboCop configuration file

Put this into your `.rubocop.yml`.

```yaml
require: rubocop-ipepe
```

Alternatively, use the following array notation when specifying multiple extensions.

```yaml
require:
  - rubocop-other-extension
  - rubocop-ipepe
```

Now you can run `rubocop` and it will automatically load the RuboCop Ipepe
cops together with the standard cops.

### Command line

```bash
rubocop --require rubocop-ipepe
```

### Rake task

```ruby
RuboCop::RakeTask.new do |task|
  task.requires << 'rubocop-ipepe'
end
```

## The Cops

All cops are located under
[`lib/rubocop/cop/ipepe`](lib/rubocop/cop/ipepe), and contain
examples/documentation.

In your `.rubocop.yml`, you may treat the Ipepe cops just like any other
cop. For example:

```yaml
Ipepe/SpecificMatcher:
  Exclude:
    - spec/my_spec.rb
```

### Ipepe/MultipleConditionUnless

Checks for multiple conditions in `unless` statement.

```ruby
# bad
unless foo && bar
  do_something
end

# good
if !(foo && bar)
  do_something
end
```

### Ipepe/TernaryOperator

Prohibits any use of ternary operator.

```ruby
# bad
foo ? bar : baz

# good
if foo
  bar
else
  baz
end
```

## Development

### Adding a new cop
`bundle exec rake 'new_cop[Ipepe/TestOperator]'`

## License

`rubocop-ipepe` is MIT licensed. [See the accompanying file](LICENSE.md) for
the full text.