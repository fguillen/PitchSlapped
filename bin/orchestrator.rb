#!/usr/bin/env ruby

require_relative "../lib/pitch_slapped"

def main
  if ARGV.length < 1
    puts "Error: Required arguments required: industry [num_companies] [num_contacts]"
    exit(1)
  end

  exclude_companies =
    File.exist?("#{PitchSlapped::Utils.root_dir}/data/already_contacted_companies.txt") ?
    File.read("#{PitchSlapped::Utils.root_dir}/data/already_contacted_companies.txt").split("\n") :
    []

  generator =
    PitchSlapped::Orchestrator.new(
      industry: ARGV[0],
      num_companies: (ARGV[1] || 5).to_i,
      num_contacts: (ARGV[2] || 3).to_i,
      exclude_companies:
    )
  generator.call
end

if __FILE__ == $0
  main
end
