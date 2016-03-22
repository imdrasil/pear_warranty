# PearWarranty

An easy to use simple gem that allow you to check your IPhone warranty information from _https://selfsolve.apple.com_ using your IMEI. One more thing - no GSX account needed.

This gem use _https://www.proxfree.com_ to not be banned by IP. That`s why we get a little bit slowly request but there is no another free and simple way to get access to your warranty information.

Last test on real imei was on July, 2015.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'pear_warranty', git: 'https://github.com/imdrasil/pear_warranty.git', branch: 'master'
```

And then execute:

    $ bundle

The latest version of gem is on master branch.

## Usage

To get warranty information about your IPhone just call:
```
PearWarranty::Parser.check('your IMEI here')
```
That call return hash with warranty information. If your device is out of Repairs and Service Coverage it will return hash:
```
{
    warranty: false,
    date: nil
}
```
In another situation it returns hash with `true` for `:warranty` key and `Date` object of estimated expiration date for `:date`. If there is error with proxy server or your IMEI hash with `:error` key and description message will be returned.

Also your can specify proxy name domain:
```
PearWarranty::Parser.check('your IMEI here', 'qc')
```
Proxy index must be in range of 0 and `PearWarranty::PROXIES.size`. If it goes out randomly chosen will be used.

### Available proxies:

* qc - Canada East
* def - Germany
* al - France (Strasbourg)
* nl - Netherlands
* fr - France (Roubaix)
* no - France (Gravelines)
* tx - United States Central (TX)
* nj - United States East (NJ)
* il - United States Central (IL)
* ga - United States East (GA)

To improve speed your should to test which of proxies works for you most frequently. For my location (Ukraine) speed test show that result (each one is for 50 requests):

Location | Speed
:--------:|:----:
Canada | 94.452161
Germany | 138.392749
Strasbourg | 79.161559
Netherlands | 133.401920
Roubaix | 70.684222
Gravelines | 71.803946
TX | 83.853322
NJ | 75.568946
IL | 103.772447
GA | 75.414354

That`s why I prefer to use France (Roubaix) - 4th proxy.

### Configuration
You can specify such parameters:

Parameter | Description | Default value
:--------:|:-----------:|:------------:
default_proxy | proxy, which is used every time for first request | 'qc'
use_list | array of proxies which be used for searching | `%w(qc def al nl fr no tx nj il ga)`
switch_proxy | `:random` - proxy will be switched in random order; `:given` - in `use_list` order | :random
max_retries | maximum retries | 10
cookie | hash with default cookies | default set is given but may be invalid for now (hardcoded for use in project)

## Dependencies

- mechanize
- http-cookie
- ruby 1.9.2 or newer

## Developers

Run all tests with:
```
rspec spec
```

## Contributing

1. Fork it ( https://github.com/imdrasil/pear_warranty/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## License

This gem is distributed under the MIT license. Please see the LICENSE file.
