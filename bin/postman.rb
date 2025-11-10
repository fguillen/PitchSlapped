#!/usr/bin/env ruby

require_relative "../lib/pitch_slapped"

def main
  if ARGV.length < 2
    puts "Usage: ruby scripts/postman.rb <EMAIL_DRAFTS_DIR_PATH> <FROM_NAME> [<CC_EMAIL>] [<BCC_EMAIL>]"
    exit(1)
  end

  postman =
    PitchSlapped::Postman.new(
      email_drafts_dir_path: ARGV[0],
      from_name: ARGV[1],
      cc_email: ARGV[2] || nil,
      bcc_email: ARGV[3] || nil
    )

  postman.send_emails
end

if __FILE__ == $0
  main
end
