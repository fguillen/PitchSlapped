require_relative "pitch_slapped"

module PitchSlapped
  class Postman
    def initialize(
      email_drafts_dir_path:,
      from_name:,
      cc_email: nil,
      bcc_email: nil
    )
      @email_drafts_dir_path = email_drafts_dir_path
      @from_name = from_name
      @cc_email = (cc_email.nil? || cc_email.empty?) ? nil : cc_email
      @bcc_email = (bcc_email.nil? || bcc_email.empty?) ? nil : bcc_email
    end

    def send_emails
      email_drafts_file_paths = Dir.glob(File.join(@email_drafts_dir_path, "**", "*.json"))
      email_drafts_file_paths.each_with_index do |draft_path, index|
        puts "Processing draft[#{index}]: #{draft_path}"
        email_content = File.read(draft_path)
        email_hash = JSON.parse(email_content)
        signature = File.exist?("#{Utils.root_dir}/data/email_signature.html") ? File.read("#{Utils.root_dir}/data/email_signature.html") : nil

        email_sender =
          EmailSender.new(
            from_name: @from_name,
            to_name: email_hash["contact_name"],
            to_email: email_hash["email_address"],
            subject: email_hash["subject_line"],
            body: email_hash["email_body"],
            signature:,
            cc_email: @cc_email,
            bcc_email: @bcc_email
          )

        puts "Sending email..."
        puts email_sender.email.to_s
        email_sender.send_email
      end
    end
  end
end
