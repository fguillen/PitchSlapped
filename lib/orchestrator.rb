module PitchSlapped
  class Orchestrator
    def initialize(
      industry:,
      num_companies: 10,
      num_contacts: 3,
      exclude_companies: []
    )
      @industry = industry
      @num_companies = num_companies
      @num_contacts = num_contacts
      @exclude_companies = exclude_companies

      @companies = nil
      @companies_contacts = nil
      @email_drafts = nil
      @output_dir_path = "results/orchestrator_#{timestamp}"
    end

    def call
      @companies = find_companies
      @companies_contacts = find_companies_contacts
      @email_drafts = generate_email_drafts
    end

    def find_companies
      agent_companies_finder =
        Agent::CompaniesFinder.new(
          industry: @industry,
          num_companies: @num_companies,
          exclude_companies: @exclude_companies,
          output_dir_path: @output_dir_path
        )
      agent_companies_finder.call
      agent_companies_finder.save_response
      agent_companies_finder.response["companies"]
    end

    def find_companies_contacts
      @companies.flat_map do |company|
        company_name = company["name"]
        agent_contacts_finder =
          Agent::CompanyContactsFinder.new(
            company_name: company_name,
            industry: company["industry"] || "N/A",
            num_contacts: @num_contacts,
            output_dir_path: "#{@output_dir_path}/company_contacts/#{sanitize_for_filename(company_name)}"
          )
        agent_contacts_finder.call
        agent_contacts_finder.save_response
        agent_contacts_finder.response["company_contacts"]
      end
    end

    def generate_email_drafts
      @companies_contacts.map do |contact|
        company_name = contact["company_name"]
        contact_name = contact["name"] || "N/A"

        agent_email_generator =
          Agent::EmailCopywriter.new(
            company_name: company_name,
            industry: contact["industry"] || "N/A",
            contact_name: contact_name,
            contact_position: contact["position"] || "N/A",
            contact_linkedin: contact["linkedin_url"] || "N/A",
            contact_email: contact["email"] || contact["inferred_email"] || "N/A",
            contact_projects: contact["projects"] || "N/A",
            output_dir_path: "#{@output_dir_path}/email_drafts/#{sanitize_for_filename(company_name)}_#{sanitize_for_filename(contact_name)}"
          )
        agent_email_generator.call
        agent_email_generator.save_response
        agent_email_generator.response
      end
    end

    def timestamp
      Time.now.strftime("%Y%m%d_%H%M%S")
    end

    def log(message)
      File.open("#{File.dirname(__FILE__)}/../logs/agents.log", "a") do |file|
        file.puts "[#{timestamp}] [#{self.class.name}] #{message}"
      end
    end

    def sanitize_for_filename(name)
      name.gsub(/\s+/, "_").gsub(/\W/, "").downcase
    end
  end
end
