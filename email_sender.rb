#!/usr/bin/env ruby
# frozen_string_literal: true

require "bundler/inline"

# Gemfile for inline dependencies
gemfile do
  source "https://rubygems.org"
  gem "mail"
  gem "dotenv"
end

require "mail"
require "dotenv/load"

# Configure the mailer with your Gmail credentials
Mail.defaults do
  delivery_method :smtp, {
    :address              => "smtp.gmail.com",
    :port                 => 587,
    :user_name            => ENV["GMAIL_ACCOUNT"],
    :password             => ENV["GMAIL_PASSWORD"],
    :authentication       => :login,
    :enable_starttls_auto => true
  }
end

# Create and send the email
Mail.deliver do
  from "Your Name <#{ENV["GMAIL_ACCOUNT"]}>"
  to "example@example.com"
  subject "Hello from my Ruby script (using Mail gem)"
  body "This is a simple test email."
end

puts "Email sent successfully!"
