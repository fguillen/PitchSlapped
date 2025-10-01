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
  def initialize(api_key:, csv_file:, output_file:, prompt_file:)
    @api_key = api_key
    @csv_file = csv_file
    @output_file = output_file
    @prompt_file = prompt_file
    @client = nil
    @prompt_template = nil
  end

  def generate_emails
    validate_files
    setup_client
    load_prompt_template
    process_csv_file
  rescue => e
    puts "Fatal error: #{e.message}"
    puts e.backtrace if ENV["DEBUG"]
    exit 1
  end

  private

  def setup_client
    RubyLLM.configure do |config|
      config.openrouter_api_key = @api_key
      config.default_model = "perplexity/sonar"
    end

    @client = RubyLLM.chat
  end

  def validate_files
    unless File.exist?(@prompt_file)
      puts "Error: Prompt file "#{@prompt_file}" not found"
      exit 1
    end

    unless File.exist?(@csv_file)
      puts "Error: CSV file "#{@csv_file}" not found"
      exit 1
    end
  end

  def load_prompt_template
    # Read the prompt template from prompt.md
    @prompt_template = File.read(@prompt_file)

    # Validate that template contains required placeholders
    required_placeholders = ["[COMPANY_NAME]", "[INDUSTRY]", "[CONTACT_NAME]", "[CONTACT_LINKEDIN]"]
    missing_placeholders = required_placeholders.reject { |placeholder| @prompt_template.include?(placeholder) }

    if missing_placeholders.any?
      puts "Warning: Prompt template is missing placeholders: #{missing_placeholders.join(", ")}"
      puts "The email generation may not work as expected."
    end
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

        # Validate required fields
        unless validate_row(row)
          error_count += 1
          next
        end

        # Generate email for this contact
        email_content = generate_email_for_contact(row)

        if email_content == "Error generating email content"
          error_count += 1
          next
        end

        # Write to markdown file
        write_email_to_markdown(output, row, email_content)
        processed_count += 1
      end
    end

    puts "\n" + "="*50
    puts "Email generation completed!"
    puts "Successfully processed: #{processed_count} contacts"
    puts "Errors encountered: #{error_count} contacts" if error_count > 0
    puts "Output saved to: #{@output_file}"
    puts "="*50
  end

  def validate_row(row)
    required_fields = ["company_name", "industry", "contact_name", "contact_linkedin"]
    missing_fields = required_fields.select { |field| row[field].nil? || row[field].strip.empty? }

    if missing_fields.any?
      puts "Warning: Skipping row due to missing fields: #{missing_fields.join(", ")}"
      return false
    end
    true
  end

  def generate_email_for_contact(row)
    # Replace placeholders in the prompt template
    personalized_prompt = @prompt_template
      .gsub("[COMPANY_NAME]", row["company_name"])
      .gsub("[INDUSTRY]", row["industry"])
      .gsub("[CONTACT_NAME]", row["contact_name"])
      .gsub("[CONTACT_LINKEDIN]", row["contact_linkedin"])

    begin
      # Send request to LLM using RubyLLM
      response = @client.ask(personalized_prompt)
      response.content || "Error generating email content"
    rescue => e
      puts "Error generating email for #{row["contact_name"]}: #{e.message}"
      "Error generating email content"
    end
  end

  def write_email_to_markdown(output, row, email_content)
    output.puts "# Email to: #{row["contact_name"]}\n"
    output.puts "- **Company:** #{row["company_name"]}"
    output.puts "- **Industry:** #{row["industry"]}"
    output.puts "- **Contact:** #{row["contact_name"]}"
    output.puts "- **LinkedIn:** #{row["contact_linkedin"]}\n"

    # Parse email content to extract subject and body
    subject, body = parse_email_content(email_content)

    output.puts "## #{subject}\n"
    output.puts "#{body}\n"
    output.puts "---\n"
  end

  def parse_email_content(content)
    # Try to extract subject line (usually starts with "Subject:" or is on first line)
    lines = content.split("\n").map(&:strip).reject(&:empty?)

    subject_line = lines.find { |line| line.downcase.start_with?("subject:") }

    if subject_line
      subject = subject_line.sub(/^subject:\s*/i, "")
      body_start_index = lines.index(subject_line) + 1
      body = lines[body_start_index..-1].join("\n\n")
    else
      # If no explicit subject line, use first line as subject and rest as body
      subject = lines.first || "Follow-up from Lufthansa Innovation Hub"
      body = lines[1..-1]&.join("\n\n") || content
    end

    [subject, body]
  end
end

# Main execution
if __FILE__ == $PROGRAM_NAME
  # Configuration
  api_key = ENV["OPEN_ROUTER_API_KEY"]
  csv_file = ARGV[0] || "contacts.csv"
  output_file = ARGV[1] || "generated_emails.md"
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
