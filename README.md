# Focuslight::Validator

Validate http request parameters (or others) by defined rule, without models.

SYNOPSIS:

```ruby
require 'focuslight-validator'
    
result = Focuslight::Validator.validate(params, {
  :request_param_key_name => { # single key, single value
    default: default_value,
    rule: [
      Focuslight::Validator.rule(:not_blank),
      Focuslight::Validator.rule(:int_range, 0..10),
    ],
  },
  array_value_key_name: { # single key, array value
    array: true
    size: 1..10 # default is unlimited (empty also allowed)
    # default cannot be used
    rule: [ ... ]
  },
  # ...
  [:param1, :param2, :param3] => { # rule for combination of 2 or more params
    # default cannot be used
    rule: Focuslight::Validator::Rule.new(->(p1, p2, p3){ ... }, "error_message")
  },
})
    
result.has_error? #=> true/false
result.errors #=> Hash ( { param_name => "error message" } )
result.hash   #=> Hash ( contains formatted values )
```

## Installation

Add this line to your application's Gemfile:

    gem 'focuslight-validator'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install focuslight-validator

## Usage

### Available built-in rules

#### not_blank

**valid if value is NOT `nil` or NOT empty**

- return stripped String (`.strip`)

```ruby
params = { v1: 'Foooo!!!!   ', v2: '' }
rule = Focuslight::Validator.rule(:not_blank)
result = Focuslight::Validator.validate(
  params,
  v1: { rule: rule },
  v2: { rule: rule },
)

p result.has_error? #=> true
p result.errors     #=> {:v2=>"v2: missing or blank"}
p result.hash       #=> {:v1=>"Foooo!!!!"}
```

#### choice

**valid if value is included in specified array**

- return untouched value 

```ruby
params = { v1: 'yellow', v2: 'gold' }
rule = Focuslight::Validator.rule(:choice, %w[ yellow red ])
result = Focuslight::Validator.validate(
  params,
  v1: { rule: rule },
  v2: { rule: rule },
)

p result.has_error? #=> true
p result.errors     #=> {:v2=>"v2: invalid value"}
p result.hash       #=> {:v1=>"yellow"}
```

#### int

**valid if value is integer**

- return value converted to Integer (`.to_i`)

```ruby
params = { v1: '-3104', v2: '3.104' }
rule = Focuslight::Validator.rule(:int)
result = Focuslight::Validator.validate(
  params,
  v1: { rule: rule },
  v2: { rule: rule },
)

p result.has_error? #=> true
p result.errors     #=> {:v2=>"v2: invalid integer"}
p result.hash       #=> {:v1=>-3104}
```

#### uint

**valid if value is 0 or natural number**

- return value converted to Integer (`.to_i`)

```ruby
params = { v1: '3104', v2: '-3104' }
rule = Focuslight::Validator.rule(:uint)
result = Focuslight::Validator.validate(
  params,
  v1: { rule: rule },
  v2: { rule: rule },
)

p result.has_error? #=> true
p result.errors     #=> {:v2=>"v2: invalid integer (>= 0)"}
p result.hash       #=> {:v1=>3104}
```

#### natural

**valid if value is natural number**

- return value converted to Integer (`.to_i`)

```ruby
params = { v1: '3104', v2: '0' }
rule = Focuslight::Validator.rule(:natural)
result = Focuslight::Validator.validate(
  params,
  v1: { rule: rule },
  v2: { rule: rule },
)

p result.has_error? #=> true
p result.errors     #=> {:v2=>"v2: invalid integer (>= 1)"}
p result.hash       #=> {:v1=>3104}
```

#### float, double, real

**valid if value is integer or decimal(include the exponential notation)**

- return value converted to Float (`.to_f`)

```ruby
params = { v1: '3.104', v2: '3104', v3: '3.104e-03', v4: 'three' }
rule = Focuslight::Validator.rule(:float)
result = Focuslight::Validator.validate(
  params,
  v1: { rule: rule }, v2: { rule: rule },
  v3: { rule: rule }, v4: { rule: rule },
)

p result.has_error? #=> true
p result.errors     #=> {:v4=>"v4: invalid floating point num"}
p result.hash       #=> {:v1=>3.104, :v2=>3104.0, :v3=>0.003104}
```

#### int_range

**valid if value is included in specified range of integer**

- return value converted to Integer (`.to_i`)

```ruby
params = { v1: '3104', v2: '3.104', v3: '-1' }
rule = Focuslight::Validator.rule(:int_range, 0..10000)
result = Focuslight::Validator.validate(
  params,
  v1: { rule: rule },
  v2: { rule: rule },
  v3: { rule: rule },
)

p result.has_error? #=> true
p result.errors     #=> {:v3=>"v3: invalid number in range 0..10000"}
p result.hash       #=> {:v1=>3104, :v2=>3}
```

#### bool

**valid if value is true, false, 1 or 0**

- return true or false

```ruby
params = { v1: 'true', v2: '0', v3: 'FalseClass' }
rule = Focuslight::Validator.rule(:bool)
result = Focuslight::Validator.validate(
  params,
  v1: { rule: rule },
  v2: { rule: rule },
  v3: { rule: rule },
)

p result.has_error? #=> true
p result.errors     #=> {:v3=>"v3: invalid bool value"}
p result.hash       #=> {:v1=>true, :v2=>false}
```

#### regexp

**valid if value is matched specified regexp**

- return untouched value

```ruby
params = { v1: 'Foooo!!!!   ', v2: '' }
rule = Focuslight::Validator.rule(:regexp, /^F.*/)
result = Focuslight::Validator.validate(
  params,
  v1: { rule: rule },
  v2: { rule: rule },
)

p result.has_error? #=> true
p result.errors     #=> {:v2=>"v2: invalid input for pattern ^F.*"}
p result.hash       #=> {:v1=>"Foooo!!!!   "}
```

### Lambda rule

If you want to validate by the rule of non existing definition, you can use rule that define by yourself.

#### example

**validation of message body size limit**

```ruby
params = { message: 'focuslight-validator is so awesome!!' }
result = Focuslight::Validator.validate(
  params,
  message: {
    rule: Focuslight::Validator.rule(
      :lambda,
      ->(m) { m && (1..10000).include?(m.strip.length) },
      'invalid length', :strip
    ),
  },
)

p result.has_error? #=> false
p result.errors     #=> {}
p result.hash       #=> {:message=>"focuslight-validator is so awesome!!"}
```

### Single value validation

validation of data having a single value

```ruby
params = { v1: nil, v2: nil, v3: nil }
rule = Focuslight::Validator.rule(:int)
result = Focuslight::Validator.validate(
  params,
  v1: { rule: rule },
  v2: { rule: rule, default: '100' },
  v3: { rule: rule, excludable: true },
)

p result.has_error? #=> true
p result.errors     #=> {:v1=>"v1: invalid integer"}
p result.hash       #=> {:v2=>100, :v3=>nil}
```

##### options

- default
  - specify `String` value
  - default value when value is `nil`
- excludable
  - specify `true` or `false`
  - apply `nil` to result when value is `nil`

### Array value validation

validation of data having array in the value

```ruby
params = { v1: %w[ 10 20 30 ], v2: %w[ 3104 ] }
rule = Focuslight::Validator.rule(:int)
result = Focuslight::Validator.validate(
  params,
  v1: { array: true, rule: rule },
  v2: { array: true, rule: rule, size: 5..10 },
  v3: { array: true, rule: rule, excludable: true },
)

p result.has_error? #=> true
p result.errors     #=> {:v2=>"v2: doesn't have values specified: 5..10"}
p result.hash       #=> {:v1=>[10, 20, 30], :v3=>[]}
```

##### options

- array
  - `true` or `false`
  - Whether to validate of data having array in the value
- size
  - `Range`
  - Specify allowable size of array
- excludable
  - apply empty array when value is `nil`

### Combination validation

complex validation for multiple values

```ruby
params = { v1: '10', v2: '20', v3: '30' }
rule = Focuslight::Validator.rule(:int)
result = Focuslight::Validator.validate(
  params,
  v1: { rule: rule },
  v2: { rule: rule },
  v3: { rule: rule },
  [ :v1, :v2, :v3 ] => {
    rule: Focuslight::Validator::Rule.new(
      -> (x, y, z) { x.to_i + y.to_i + z.to_i < 15 },
      'too large'
    )
  },
)

p result.has_error? #=> true
p result.errors     #=> {:"v1,v2,v3"=>"v1,v2,v3: too large"}
p result.hash       #=> {:v1=>10, :v2=>20, :v3=>30}
```

##### attention

- cannot use `built-in rules`

## Contributing

1. Fork it ( http://github.com/<my-github-username>/focuslight-validator/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
