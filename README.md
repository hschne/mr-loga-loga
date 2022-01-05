<div align="center">

# Mr. Loga Loga

<img alt="logo" src="logo.png" width="300px" height="auto">

### The simply bombastic, fantastic logger for Ruby 💎

[![Gem Version](https://badge.fury.io/rb/mr_loga_loga.svg)](https://badge.fury.io/rb/mr_loga_loga)
[![Main](https://github.com/hschne/mr-loga-loga/actions/workflows/main.yml/badge.svg)](https://github.com/hschne/mr-loga-loga/actions/workflows/main.yml)
![License](https://img.shields.io/github/license/hschne/mr-loga-loga)
</div>

## What's this?

MrLogaLoga is a logger for Ruby that allows you to easily attach contextual information to your log messages. 
When writing logs, messages only tell half the story. MrLogaLoga allows you to make the most of your logs.

```ruby
logger.info('message', user: 'name', data: 1)
# I, [2022-01-01T12:00:00.000000 #19074]  INFO -- Main: message user=user data=1
```

You can find out more about the motivation behind the project [here](#why-mrlogaloga). For usage read [Usage](#usage) or [Advanced Usage](#advanced-usage)

**Note**: This gem is in early development. Try it out and leave some feedback, it really goes a long way in helping me out with development. Any [feature request](https://github.com/hschne/mr-loga-loga/issues/new?assignees=&labels=type%3ABug&template=FEATURE_REQUEST.md&title=) or [bug report](https://github.com/hschne/mr-loga-loga/issues/new?assignees=&labels=type%3AEnhancement&template=BUG_REPORT.md&title=) is welcome. If you like this project, leave a star to show your support! ⭐

## Getting Started

Add this line to your application's Gemfile:

```ruby
gem 'mr_loga_loga'
```

And then execute:

```
bundle install
```

## Usage

MrLogaLoga provides the same interface as the Ruby default logger you are used to. In addition, however, you can attach contextual information to your log messages.

```ruby
require 'mr_loga_loga'

logger = MrLogaLoga::Logger.new
logger.info('message', user: 'name', data: 1) 
# I, [2022-01-01T12:00:00.000000 #19074]  INFO -- Main: message user=user data=1
logger.context(class: 'classname').warn('message') 
# W, [2022-01-01T12:00:00.000000 #19074]  WARN -- Main: message class=classname
```

To customize how log messages are formatted see [Formatters][#formatters].

## Advanced Usage

MrLogaLoga provides a fluent interface to build log messages. For example, to attach an additional `user` field to a log message you can use any of the following:

```ruby
logger.info('message', user: 'name')
logger.context(user: 'name').info('message') # Explicit context
logger.context { { user: 'name' } }.info('message') # Block context
logger.user('name').info('message') # Dynamic context method
logger.user { 'name' }.info('message') # Dynamic context block
```

The block syntax [ is recommended when logging calculated properties ](https://ruby-doc.org/stdlib-2.4.0/libdoc/logger/rdoc/Logger.html#class-Logger-label-How+to+log+a+message). You can find more in-depth information about specific method in the [Code Documentation](./doc).

#### Shared Context

If multiple log messages within the same class should share a context include the `MrLogaLoga` module. Using `logger` will result in the defined context being included per default:

```ruby
class MyClass 
  include MrLogaLoga

  # This is the default. You may overwrite this in your own classes
  def loga_context 
     { class_name: self.class.name } 
  end

  def log
   # This includes the class name in the log message now
   logger.debug('debug') # debug class_name=MyClass
   # Additional context will be merged
   logger.debug('debug', user: 'user') # debug class_name=MyClass user=user
  end
end
```

When used with [Rails](#rails) logger will default to `Rails.logger`. If you use MrLogaLoga outside of Rails, you can either configure the logger instance to be used globally, or by overwriting the `loga_loga` method:

```ruby
# In some configuration class
MrLogaLoga.configure do |configuration|
  logger = MrLogaLoga::Logger.new($stdout)
end

# In the class where you do the logging itself
class MyClass 
  include MrLogaLoga

  def loga_loga
    MrLogaLoga::Logger.new($stdout)
  end

  def log
    # ...
  end
end
```

### Formatters

MrLogaLoga uses the [KeyValue](https://github.com/hschne/mr-loga-loga/blob/main/lib/mr_loga_loga/formatters/key_value.rb) formatter per default. The [Json](https://github.com/hschne/mr-loga-loga/blob/main/lib/mr_loga_loga/formatters/json.rb) formatter is also included. To use a specific formatter pass it to the logger constructor:

```Ruby

MrLogaLoga::Logger.new(STDOUT, formatter: MrLogaLoga::Formatters::KeyValue.new)
```

You can implement and add your own formatters like so:

```ruby
class MyFormatter
  def call(severity, datetime, progname, message, context)
    context = context.map { |key, value| "#{key}=#{value}" }.compact.join(' ')
    "#{severity} #{datetime.strftime('%Y-%m-%dT%H:%M:%S.%6N')} #{progname} #{message} #{context}"
  end
end

MrLogaLoga::Logger.new(STDOUT, formatter: MyFormatter.new)
```

### Rails

Using MrLogaLoga in Ruby on Rails is straightforward. Set up MrLogaLoga as logger in your `application.rb` or environment files and you are off to the races:

```ruby
# application.rb
config.logger = MrLogaLoga::Logger.new(STDOUT)
config.log_level = :info
```

Note that setting `config.log_formatter` does not work. You must set the formatter in the logger constructor as described in [Formatters](#formatters).

### Lograge

[LogRage](https://github.com/roidrage/lograge) and MrLogaLoga work well together. When using both gems Lograge will be patched so that data will be available as `context` in MrLogaLoga. Make sure that MrLogaLoga is required **after** Lograge: 

```ruby
gem 'lograge'
gem 'mr_loga_loga'
```

Note that Lograge's formatters won't be used. Use MrLogaLoga's own [formatters](#formatters) instead.

## Why MrLogaLoga?

The more context your logs provide, the more use you will get out of them. The standard Ruby logger only takes a string as an argument, so you have to resort to something like this:

```ruby
logger.debug("my message user=#{user} more_data=#{data}")
```

This is fine, as long as you do not need to change your log format. Changing your log formatter will not change the format of your message, nor the formatting of the contextual information you provided.

MrLogaLoga addresses this by allowing you to attach contextual information to your logs and giving you full control over how both message and context are formatted. There are other gems doing similar things, most notably [Semantic Logger](https://logger.rocketjob.io/). Where Semantic Logger provides lots of functionality related to logging, MrLogaLoga focuses on making it nice to write log messages - and nothing more. 

## Credit

This little library was inspired by [Lograge](https://github.com/roidrage/lograge) first and foremost. I would like to thank the amazing [@LenaSchnedlitz](https://twitter.com/LenaSchnedlitz) for the incredible logo! 🤩

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake` to run the tests and linter. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Thank you for contributing! :heart:

We welcome all support, whether on bug reports, code, design, reviews, tests, documentation, translations, or just feature requests.

Please use [GitHub issues](https://github.com/hschne/rails-mini-profiler/issues) to submit bugs or feature requests.

## License

The gem is available as open-source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the MrLogaLoga project's codebases, issue trackers, chat rooms, and mailing lists is expected to follow the [code of conduct](https://github.com/hschne/mr_loga_loga/blob/master/CODE_OF_CONDUCT.md).
