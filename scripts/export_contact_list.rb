require "json"
require "debug"
require "csv"

class ExportContactList
  def self.run
    all_companys_contacts = load_all_company_contacts

    csv_filename = "#{__dir__}/../results/exported_contacts_#{Time.now.strftime("%Y%m%d_%H%M%S")}.csv"
    CSV.open(csv_filename, "w", write_headers: false) do |csv|
      all_companys_contacts.each do |contact|
        csv << [
          contact["company_name"],
          contact["name"],
          "Fernando",
          contact["industry"],
          "",
          "",
          contact["position"],
          contact["linkedin_url"],
          contact_email(contact),
          contact["projects"]
        ]
      end
    end
  end

  def self.load_all_company_contacts
    contacts_file_paths = Dir.glob(File.join("#{__dir__}/../results/orchestrator_20251106_144810/company_contacts", "**", "*.json"))
    contacts_file_paths.flat_map do |contact_path|
      content = File.read(contact_path)
      JSON.parse(content)["company_contacts"]
    end
  end

  def self.contact_email(contact)
    (contact["email"].nil? || contact["email"].empty?) ? contact["inferred_email"] : contact["email"]
  end
end

ExportContactList.run
