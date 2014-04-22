# Focuslight::Validator

Validate http request parameters (or others) by defined rule, without models.

SYNOPSIS:

    require 'focuslight-validator'
    
    result = Validator.validate(params, {
      :request_param_key_name => { # single key, single value
        :default => default_value,
        :rule => [
          Validator.rule(:not_null),
          Validator.rule(:int_range, 0..10),
        ],
      },
      :array_value_key_name => { # single key, array value
        :array => true
        :size => 1..10 # default is unlimited (empty also allowed)
        # default cannot be used
        :rule => [ ... ]
      }
      # ...
      [:param1, :param2, :param3] => { # rule for combination of 2 or more params
        # default cannot be used
        :rule => Validator::Rule.new(->(p1, p2, p3){ ... }, "error_message")
      },
    }
    
    result.has_error? #=> true/false
    result.errors #=> Hash( { param_name => "error message" } )

## Installation

Add this line to your application's Gemfile:

    gem 'focuslight-validator'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install focuslight-validator

## Usage

TBD: default/array/size/rule

### Available built-in rules

TBD

### Lambda rule

TBD

### Array value validation

TBD

### Combination validation

TBD

## Contributing

1. Fork it ( http://github.com/<my-github-username>/focuslight-validator/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
