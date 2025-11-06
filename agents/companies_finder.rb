#!/usr/bin/env ruby

require_relative "base"


module Agent
  class CompaniesFinder < Base
    class OutputSchema < RubyLLM::Schema
      array :companies do
        object :company do
          any_of :name, description: "Name of the company" do
            string
            null
          end
          any_of :industry, description: "Industry the company operates in" do
            string
            null
          end
          any_of :headquarters, description: "Location of the company's headquarters" do
            string
            null
          end
          # any_of :overview, description: "Brief overview of the company" do
          #   string
          #   null
          # end
          # any_of :market_cap_eur, description: "Market capitalization of the company in EUR" do
          #   integer
          #   null
          # end
          # any_of :yoy_revenue_eur, description: "Year-over-year revenue of the company in EUR" do
          #   integer
          #   null
          # end
          any_of :linkedin_url, description: "URL to the company's LinkedIn profile" do
            string
            null
          end
        end
      end
    end

    def initialize(
      industry:,
      num_companies: 10,
      model: "perplexity/sonar-pro-search",
      prompt_path: "#{__dir__}/../prompts/companies_finder.md",
      output_dir_path: "#{__dir__}/../results"
    )
      super(prompt_path:, model:, output_dir_path:)
      @industry = industry
      @num_companies = num_companies
    end

    def build_prompt
      @built_prompt ||=
        File.read(@prompt_path)
          .gsub("[INDUSTRY]", @industry)
          .gsub("[NUM_COMPANIES]", @num_companies.to_s)
    end

    def self.output_schema
      OutputSchema
    end
  end
end

# Main execution
def main
  if ARGV.length < 1
    puts "Error: Required arguments required: industry"
    exit(1)
  end

  agent =
    Agent::CompaniesFinder.new(
      industry: ARGV[0]
    )
  agent.call
  agent.save_response
end


if __FILE__ == $0
  main
end
