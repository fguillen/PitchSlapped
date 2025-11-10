#!/usr/bin/env ruby

require_relative "../lib/pitch_slapped"

# Example usage:
# bin/email_copywriter.rb \
#   "Bayer AG (Crop Science)" \
#   "Farming and Agriculture" \
#   "Dr. Maria Smith" \
#   "Head of Digital Farming Solutions" \
#   "https://www.linkedin.com/in/dr-maria-smith" \
#   "maria.smith@bayer.com" \
#   "Dr. Maria Smith leads initiatives in digital farming solutions, focusing on integrating Earth Observation data to enhance precision agriculture. Her team works on projects that utilize satellite imagery to monitor crop health, optimize irrigation, and predict yields, aiming to improve sustainability and productivity in agriculture."

def main
  if ARGV.length < 7
    puts "Usage: ruby email.rb <COMPANY_NAME> <INDUSTRY> <CONTACT_NAME> <CONTACT_POSITION> <CONTACT_LINKEDIN> <CONTACT_EMAIL> <CONTACT_PROJECTS>"
    exit(1)
  end

  agent =
    PitchSlapped::Agent::EmailCopywriter.new(
      company_name: ARGV[0],
      industry: ARGV[1],
      contact_name: ARGV[2],
      contact_position: ARGV[3],
      contact_linkedin: ARGV[4],
      contact_email: ARGV[5],
      contact_projects: ARGV[6]
    )
  agent.call
  agent.save_response
end

if __FILE__ == $0
  main
end
