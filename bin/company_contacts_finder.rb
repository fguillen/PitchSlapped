#!/usr/bin/env ruby

require_relative "../lib/pitch_slapped"

def process(company)
  agent =
    PitchSlapped::Agent::CompanyContactsFinder.new(
      industry: company["industry"],
      company_name: company["name"],
      num_contacts: 3
    )
  agent.call
  agent.save_response
end

def main
  if ARGV.length < 1
    puts "Error: Required arguments required: companies_filepath"
    exit(1)
  end

  companies = JSON.parse(File.read(ARGV[0]))["companies"]
  companies.each do |company|
    process(company)
  end
end

if __FILE__ == $0
  main
end
