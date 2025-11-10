#!/usr/bin/env ruby

require_relative "../lib/pitch_slapped"

def main
  if ARGV.length < 1
    puts "Error: Required arguments required: industry [num_companies]"
    exit(1)
  end

  exclude_companies =
    File.exist?("#{PitchSlapped::Utils.root_dir}/data/already_contacted_companies.txt") ?
    File.read("#{PitchSlapped::Utils.root_dir}/data/already_contacted_companies.txt").split("\n") :
    []

  agent =
    PitchSlapped::Agent::CompaniesFinder.new(
      industry: ARGV[0],
      num_companies: (ARGV[1] || 10).to_i,
      exclude_companies: exclude_companies
    )
  agent.call
  agent.save_response
end


if __FILE__ == $0
  main
end
