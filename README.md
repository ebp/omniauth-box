# OmniAuth Box Strategy for V2 API (OAuth2)

This gem provides a dead simple way to authenticate to Box using OAuth2.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'omniauth-box', git: "https://github.com/youpdidou/omniauth-box.git"
```

## Usage

First, you will need to [register an application](http://www.box.com/developers/services/new_service_terms) with Box and obtain an API key. Once you do that, you can use it like so:

```ruby
use OmniAuth::Builder do
  provider :box, 'yourapikey', 'yourapisecret'
end
```


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request