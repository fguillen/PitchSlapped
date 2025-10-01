#!/usr/bin/env ruby
# frozen_string_literal: true

require "bundler/inline"

# Gemfile for inline dependencies
gemfile do
  source "https://rubygems.org"
  gem "ruby_llm", require: "ruby_llm"
  gem "csv"
  gem "dotenv"
end

require "csv"
require "ruby_llm"
require "dotenv/load"

class EmailGenerator
  # Define schema for structured email response
  EMAIL_RESPONSE_SCHEMA = {
    type: 'object',
    properties: {
      company_name: { type: 'string' },
      industry: { type: 'string' },
      contact_name: { type: 'string' },
      contact_linkedin: { type: 'string' },
      inferred_email: { type: 'string' },
      subject: { type: 'string' },
      body: { type: 'string' }
    },
    required: %w[company_name industry contact_name contact_linkedin inferred_email subject body],
    additionalProperties: false
  }.freeze

  def initialize(api_key:, csv_file:, output_file:, prompt_file:)
    @api_key = api_key
    @csv_file = csv_file
    @output_file = output_file
    @prompt_file = prompt_file
    @client = nil
    @prompt_template = nil
  end

  def generate_emails
    setup_client
    load_prompt_template
    process_csv_file
  end

  private

  def setup_client
    RubyLLM.configure do |config|
      config.openrouter_api_key = @api_key
      config.default_model = "perplexity/sonar"
    end

    @client = RubyLLM.chat
  end

  def load_prompt_template
    @prompt_template = File.read(@prompt_file)
  end

  def process_csv_file
    processed_count = 0
    error_count = 0

    # Initialize output markdown file
    File.open(@output_file, "w") do |output|
      output.puts "# Generated Intro Emails"
      output.puts "*Generated on #{Time.now.strftime("%Y-%m-%d %H:%M:%S")}*\n\n"

      CSV.foreach(@csv_file, headers: true) do |row|
        puts "Processing: #{row["contact_name"]} at #{row["company_name"]}"
        email_data = generate_email_for_contact(row)
        write_email_to_markdown(output, email_data)
        processed_count += 1
      end
    end

    puts "\n" + "="*50
    puts "Email generation completed!"
    puts "Successfully processed: #{processed_count} contacts"
    puts "Output saved to: #{@output_file}"
    puts "="*50
  end

  def generate_email_for_contact(row)
    personalized_prompt =
      @prompt_template
        .gsub("[COMPANY_NAME]", row["company_name"])
        .gsub("[INDUSTRY]", row["industry"])
        .gsub("[CONTACT_NAME]", row["contact_name"])
        .gsub("[CONTACT_LINKEDIN]", row["contact_linkedin"])

    response = @client.with_schema(EMAIL_RESPONSE_SCHEMA).ask(personalized_prompt)
    response.content
  end

  def write_email_to_markdown(output, email_data)
    output.puts "# Email to: #{email_data["contact_name"]}\n"
    output.puts "- **Company:** #{email_data["company_name"]}"
    output.puts "- **Industry:** #{email_data["industry"]}"
    output.puts "- **Contact:** #{email_data["contact_name"]}"
    output.puts "- **LinkedIn:** #{email_data["contact_linkedin"]}"
    output.puts "- **Inferred Email:** #{email_data["inferred_email"]}\n"

    output.puts "## #{email_data["subject"]}\n"
    output.puts "#{email_data["body"]}\n"
    output.puts "---\n"
  end
end

# Main execution
if __FILE__ == $PROGRAM_NAME
  # Configuration
  api_key = ENV["OPEN_ROUTER_API_KEY"]
  csv_file = ARGV[0] || "data/contacts.csv"
  output_file = ARGV[1] || "data/generated_emails_#{Time.now.strftime('%Y%m%d_%H%M%S')}.md"
  prompt_file = "prompt.md"

  generator =
    EmailGenerator.new(
      api_key: api_key,
      csv_file: csv_file,
      output_file: output_file,
      prompt_file: prompt_file
    )

  generator.generate_emails
end
