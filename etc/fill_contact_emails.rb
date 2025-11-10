require "json"
require "debug"

class FillContactEmails
  def self.run
    @all_companys_contacts = load_all_company_contacts
    email_drafts_file_paths = Dir.glob(File.join("#{PitchSlapped::Utils.root_dir}/results/orchestrator_20251106_144810/email_drafts", "**", "*.json"))
    email_drafts_file_paths.each do |draft_path|
      puts "Processing draft: #{draft_path}"

      email_content = File.read(draft_path)
      email_hash = JSON.parse(email_content)

      if email_hash["email_address"] == "" || email_hash["email_address"].nil?
        recued_email = email_for_contact(email_hash["contact_name"], email_hash["company_name"])
        email_hash["email_address"] = recued_email
        File.write(draft_path, JSON.pretty_generate(email_hash))
        puts "Updated email address for #{email_hash["contact_name"]} to #{recued_email}"
      else
        puts "Email address for #{email_hash["contact_name"]} is already set to #{email_hash["email_address"]}"
      end
    end
  end

  def self.load_all_company_contacts
    contacts_file_paths = Dir.glob(File.join("#{PitchSlapped::Utils.root_dir}/results/orchestrator_20251106_144810/company_contacts", "**", "*.json"))
    contacts_file_paths.flat_map do |contact_path|
      content = File.read(contact_path)
      JSON.parse(content)["company_contacts"]
    end
  end

  def self.email_for_contact(contact_name, company_name)
    contact = @all_companys_contacts.find { |e| e["company_name"] == company_name && e["name"] == contact_name }
    contact_email(contact)
  end

  def self.contact_email(contact)
    (contact["email"].nil? || contact["email"].empty?) ? contact["inferred_email"] : contact["email"]
  end
end

FillContactEmails.run
