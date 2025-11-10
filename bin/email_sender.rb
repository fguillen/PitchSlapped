#!/usr/bin/env ruby

require_relative "../lib/pitch_slapped"

def main
  if ARGV.length < 6
    puts "Usage: ruby scripts/email_sender.rb <FROM_NAME> <FROM_EMAIL> <TO_NAME> <TO_EMAIL> <SUBJECT> <BODY>"
    exit(1)
  end

  sender =
    PitchSlapped::EmailSender.new(
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
