source 'https://rubygems.org'

gem 'slather'
gem 'fastlane'
gem 'cocoapods'

if ENV['CI']
  # use HTTPS with token on Travis CI
  git_source :github do |repo_name|
    repo_name = "hyperwallet/hyperwallet-ios-insights-sdk"
    "https://#{ENV.fetch("CI_USER_TOKEN")}@github.com/#{repo_name}.git"
  end
end
