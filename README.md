# PearWarranty

An easy to use simple gem that allow you to check your IPhone warranty information from _https://selfsolve.apple.com_ using your IMEI. One more thing - no GSX account needed.

This gem use _https://www.proxfree.com_ to not be banned by IP. That`s why we get a little bit slowly request but there is no another free and simple way to get access to your warranty information.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'pear_warranty'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install pear_warranty

## Usage

To get warranty information about your IPhone just call:
```
PearWarranty.check('your IMEI here')
```
That call return hash with warranty information. If your device is out of Repairs and Service Coverage it will return hash:
```
{
    warranty: false,
    date: nil
}
```
In another situation it returns hash with `true` for `:warranty` key and `Date` object of estimated expiration date for `:date`. If there is error with proxy server or your IMEI hash with `:error` key and description message will be returned.

Also your can specify proxy index domain by passing `proxy_index` parameter:
```
PearWarranty.check('your IMEI here', 0)
```
Proxy index must be in range of 0 and `PearWarranty::PROXIES.size`. If it goes out randomly chosen will be used.

### Available proxies:

* 0 - Canada East
* 1 - Germany
* 2 - France (Strasbourg)
* 3 - Netherlands
* 4 - France (Roubaix)
* 5 - France (Gravelines)
* 6 - United States Central (TX)
* 7 - United States East (NJ)
* 8 - United States Central (IL)
* 9 - United States East (GA)

To improve speed your should to test which of proxies works for you most frequently. For my location (Ukraine) speed test show that result (each one is for 50 requests):

Proxy index | Location | Speed
:----------:|:--------:|:----:
0 | Canada | 94.452161
1 | Germany | 138.392749
2 | Strasbourg | 79.161559
3 | Netherlands | 133.401920
4 | Roubaix | 70.684222
5 | Gravelines | 71.803946
6 | TX | 83.853322
7 | NJ | 75.568946
8 | IL | 103.772447
9 | GA | 75.414354
- | random | 114.406067

That`s why I prefer to use France (Roubaix) - 4th proxy.

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
