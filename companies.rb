#!/usr/bin/env ruby

require_relative "generator"

class CompaniesGenerator < Generator
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
        any_of :overview, description: "Brief overview of the company" do
          string
          null
        end
        any_of :market_cap, description: "Market capitalization of the company in EUR" do
          integer
          null
        end
        any_of :yoy, description: "Year-over-year revenue of the company in EUR" do
          integer
          null
        end
        any_of :linked_url, description: "URL to the company's LinkedIn profile" do
          string
          null
        end
      end
    end
  end

  def initialize(prompt_path:, industry:, output_dir_path: "results", model: "perplexity/sonar-pro-search")
    super(prompt_path:, output_dir_path:, model:)
    @industry = industry
  end

  def build_prompt
    industry = @industry
    @prompt = File.read(@prompt_path).gsub("[INDUSTRY]", industry)
    @prompt
  end

  def self.output_schema
    OutputSchema
  end
end

# Main execution
def main
  if ARGV.length < 1
    puts "Error: Required arguments required: industry"
    exit(1)
  end

  generator =
    CompaniesGenerator.new(
      prompt_path: "#{__dir__}/prompts/companies.md",
      industry: ARGV[0],
    )
  generator.completion
end

if __FILE__ == $0
  main
end
