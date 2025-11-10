#!/usr/bin/env ruby

require_relative "base"

module PitchSlapped
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
        super(prompt_path:, model:, output_dir_path:, industry:)
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
  end
end
