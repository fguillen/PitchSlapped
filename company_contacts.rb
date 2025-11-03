#!/usr/bin/env ruby

require_relative "generator"

class CompanyContactsGenerator < Generator
  class OutputSchema < RubyLLM::Schema
    array :company_contacts do
      object :company_contact do
        any_of :company_name, description: "Name of the company" do
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

  def initialize(prompt_path:, company_name:, output_dir_path: "results", model: "openai/gpt-4o:online")
    super(prompt_path:, output_dir_path:, model:)
    @company_name = company_name
  end

  def build_prompt
    @prompt = File.read(@prompt_path).gsub("[COMPANY_NAME]", @company_name)
    @prompt
  end

  def self.output_schema
    OutputSchema
  end
end

# Main execution
def main
  if ARGV.length < 1
    puts "Error: Required arguments required: company_name"
    exit(1)
  end

  generator =
    CompanyContactsGenerator.new(
      prompt_path: "#{__dir__}/prompts/company_contacts.md",
      company_name: ARGV[0],
    )
  generator.completion
end

if __FILE__ == $0
  main
end
