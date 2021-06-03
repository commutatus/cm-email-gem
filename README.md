# Cm_email Gem Setup Instructions
To install the gem in your application:
```
- Add to your Gemfile: gem 'cm_email'
- Run: bundle install
```
Create a configuration file like `config/initializers/cm_email.rb`, paste the following and replace the credentials.
```
Cm_email.configure do |config|
  config.api_key = "xxxxxxxxxxxxxx"
end
```
