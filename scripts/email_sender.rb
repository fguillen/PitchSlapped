#!/usr/bin/env ruby
# frozen_string_literal: true


require "mail"
require "debug"
require "dotenv/load"
require "commonmarker"

# Example usage:
# sender =
#   EmailSender.new(
#     from_name: "Your Name",
#     from_email: "your_email@gmail.com",
#     to_name: "Recipient Name",
#     to_email: "recipient_email@example.com",
#     subject: "Hello from my Ruby script",
#     body: "This is a test email."
#   )
#
# sender.send_email

class EmailSender
  attr_reader :email

  def initialize(
    from_name:,
    from_email:,
    to_name:,
    to_email:,
    subject:,
    body:
  )
    @from_name = from_name
    @from_email = from_email
    @to_name = to_name
    @to_email = to_email
    @subject = subject
    @body = body

    configure_mail_connection
    @email = build_email
  end

  def send_email
    @email.deliver!
    puts "Email sent successfully to #{@to_email}"
  end

  private

  def configure_mail_connection
    Mail.defaults do
      delivery_method :smtp, {
        address: "smtp.gmail.com",
        port: 587,
        user_name: ENV["GMAIL_ACCOUNT"],
        password: ENV["GMAIL_PASSWORD"],
        authentication: :login,
        enable_starttls_auto: true
      }
    end
  end

  def build_email
    from_value = "#{@from_name} <#{@from_email}>"
    to_value = "#{@to_name} <#{@to_email}>"
    subject_value = @subject
    body_value = Commonmarker.to_html("#{@body} \n\n--\n")
    body_value += File.read("#{__dir__}/email_signature.html") if File.exist?("#{__dir__}/email_signature.html")

    Mail.new do
      from from_value
      to to_value
      subject subject_value
      content_type "text/html; charset=UTF-8"
      body body_value
    end
  end
end




def main
  if ARGV.length < 6
    puts "Usage: ruby scripts/email_sender.rb <FROM_NAME> <FROM_EMAIL> <TO_NAME> <TO_EMAIL> <SUBJECT> <BODY>"
    exit(1)
  end

  sender =
    EmailSender.new(
      from_name: ARGV[0],
      from_email: ARGV[1],
      to_name: ARGV[2],
      to_email: ARGV[3],
      subject: ARGV[4],
      body: ARGV[5]
    )

  puts "Sending email..."
  puts sender.email.to_s

  sender.send_email
end

if __FILE__ == $0
  main
end
