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
require "json"

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
        email_data = generate_email_for_contact(row)

        if email_data.nil?
          error_count += 1
          next
        end

        # Write to markdown file
        write_email_to_markdown(output, email_data)
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
      raw_content = response.content || "Error generating email content"

      # Parse JSON response
      parse_json_response(raw_content, row)
    rescue => e
      puts "Error generating email for #{row["contact_name"]}: #{e.message}"
      nil
    end
  end

  def parse_json_response(content, fallback_row)
    # Try to extract JSON from the response
    json_match = content.match(/```json\s*({.*?})\s*```/m) || content.match(/({.*})/m)

    if json_match
      json_string = json_match[1]
      begin
        parsed_data = JSON.parse(json_string)

        # Validate required fields
        required_fields = ["company_name", "industry", "contact_name", "contact_linkedin", "inferred_email", "subject", "body"]
        if required_fields.all? { |field| parsed_data.key?(field) }
          return parsed_data
        else
          puts "Warning: JSON response missing required fields for #{fallback_row['contact_name']}"
        end
      rescue JSON::ParserError => e
        puts "Warning: Failed to parse JSON for #{fallback_row['contact_name']}: #{e.message}"
      end
    end

    # Fallback: create structure from original data
    {
      "company_name" => fallback_row["company_name"],
      "industry" => fallback_row["industry"],
      "contact_name" => fallback_row["contact_name"],
      "contact_linkedin" => fallback_row["contact_linkedin"],
      "inferred_email" => "#{fallback_row['contact_name'].downcase.gsub(' ', '.')}@#{fallback_row['company_name'].downcase.gsub(' ', '')}.com",
      "subject" => "Partnership Opportunity: Lufthansa Innovation Hub",
      "body" => content.gsub(/```json.*?```/m, '').strip
    }
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
