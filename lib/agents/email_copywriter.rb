#!/usr/bin/env ruby

require_relative "base"

module Agent
  class EmailCopywriter < Base
    class OutputSchema < RubyLLM::Schema
      string :company_name, description: "Name of the company"
      string :contact_name, description: "Name of the contact"
      string :subject_line, description: "Subject line of the email"
      string :email_body, description: "Body of the email"
      string :email_address, description: "Inferred email address of the contact"
    end

    def initialize(
      prompt_path: "#{PitchSlapped::Utils.root_dir}/prompts/email_copywriter.md",
      model: "perplexity/sonar-pro-search",
      company_name:,
      industry:,
      contact_name:,
      contact_position:,
      contact_linkedin:,
      contact_email:,
      contact_projects:,
      output_dir_path: "#{PitchSlapped::Utils.root_dir}/results"
    )
      super(prompt_path:, model:, output_dir_path:)
      @company_name = company_name
      @industry = industry
      @contact_name = contact_name
      @contact_position = contact_position
      @contact_linkedin = contact_linkedin
      @contact_email = contact_email
      @contact_projects = contact_projects
    end

    def build_prompt
      @built_prompt ||=
        File.read(@prompt_path)
          .gsub("[COMPANY_NAME]", @company_name)
          .gsub("[INDUSTRY]", @industry)
          .gsub("[CONTACT_NAME]", @contact_name)
          .gsub("[CONTACT_POSITION]", @contact_position)
          .gsub("[CONTACT_LINKEDIN]", @contact_linkedin)
          .gsub("[CONTACT_EMAIL]", @contact_email)
          .gsub("[CONTACT_PROJECTS]", @contact_projects)
    end

    def self.output_schema
      OutputSchema
    end
  end

  # Main execution
  # Example usage:
  # ruby agents/email.rb \
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
      EmailCopywriter.new(
        company_name: ARGV[0],
        industry: ARGV[1],
        contact_name: ARGV[2],
        contact_position: ARGV[3],
        contact_linkedin: ARGV[4],
        contact_email: ARGV[5],
        contact_projects: ARGV[6]
      )
    agent.completion
  end

  if __FILE__ == $0
    main
  end
end
