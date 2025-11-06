#!/usr/bin/env ruby

require_relative "base"

module Agent
  class CompanyContactsFinder < Base
    class OutputSchema < RubyLLM::Schema
      array :company_contacts do
        object :company_contact do
          any_of :company_name, description: "Name of the company" do
            string
            null
          end
          any_of :industry, description: "Industry the company operates in" do
            string
            null
          end
          any_of :name, description: "Name of the contact person" do
            string
            null
          end
          any_of :position, description: "Position of the contact person" do
            string
            null
          end
          any_of :linkedin_url, description: "LinkedIn profile URL of the contact person" do
            string
            null
          end
          any_of :email, description: "Find the email on the internet (leave blank if not found)" do
            string
            null
          end
          any_of :inferred_email, description: "If the email is not found, generate a plausible email address based on the typical email structure of other addresses at their company." do
            string
            null
          end
          any_of :projects, description: "What projects are they working on related to Earth Observation data, and what uses can they make of such data?" do
            string
            null
          end
        end
      end
    end

    def initialize(
      prompt_path: "#{__dir__}/../prompts/company_contacts_finder.md",
      company_name:,
      industry:,
      num_contacts: 3,
      output_dir_path: "#{__dir__}/../results",
      model: "perplexity/sonar-pro-search"
    )
      super(prompt_path:, model:, output_dir_path:)
      @company_name = company_name
      @industry = industry
      @num_contacts = num_contacts
    end

    def build_prompt
      @built_prompt ||=
        File.read(@prompt_path)
          .gsub("[COMPANY_NAME]", @company_name)
          .gsub("[INDUSTRY]", @industry)
          .gsub("[NUM_CONTACTS]", @num_contacts.to_s)
    end

    def self.output_schema
      OutputSchema
    end
  end

  # Main execution
  def main
    if ARGV.length < 2
      puts "Error: Required arguments required: company_name, industry"
      exit(1)
    end

    agent =
      CompanyContactsFinder.new(
        company_name: ARGV[0],
        industry: ARGV[1]
      )
    agent.completion
  end

  if __FILE__ == $0
    main
  end
end
