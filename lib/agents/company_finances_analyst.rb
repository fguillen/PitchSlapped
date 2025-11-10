#!/usr/bin/env ruby

require_relative "base"

module Agent
  class CompanyFinancesAnalyst < Base
    class OutputSchema < RubyLLM::Schema
      string :company_name, description: "Name of the company"
      integer :market_cap_eur, description: "Market capitalization of the company in EUR"
      integer :yoy_revenue_eur, description: "Year-over-year revenue of the company in EUR"
    end

    def initialize(
      company_name:,
      industry:,
      prompt_path: "#{PitchSlapped::Utils.root_dir}/prompts/company_finances_analyst.md",
      output_dir_path: "#{PitchSlapped::Utils.root_dir}/results",
      model: "perplexity/sonar-pro-search"
    )
      super(prompt_path:, output_dir_path:, model:)
      @company_name = company_name
      @industry = industry
    end

    def build_prompt
      File.read(@prompt_path)
        .gsub("[COMPANY_NAME]", @company_name)
        .gsub("[INDUSTRY]", @industry)
    end

    def self.output_schema
      OutputSchema
    end
  end
end

  # Main execution
def main
  if ARGV.length != 2
    puts "Usage: ruby agents/company_finances_analyst.rb \"Company Name\" \"Industry\""
    exit(1)
  end

  agent =
    Agent::CompanyFinancesAnalyst.new(
      company_name: ARGV[0],
      industry: ARGV[1]
    )
  agent.call
  agent.save_response
end

if __FILE__ == $0
  main
end
