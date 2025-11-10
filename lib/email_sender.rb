require_relative "pitch_slapped"
require "mail"

module PitchSlapped
  class EmailSender
    attr_reader :email

    def initialize(
      from_name:,
      to_name:,
      to_email:,
      subject:,
      body:,
      signature: nil,
      cc_email: nil,
      bcc_email: nil
    )
      @from_name = from_name
      @to_name = to_name
      @to_email = to_email
      @subject = subject
      @body = body
      @signature = signature
      @cc_email = cc_email
      @bcc_email = bcc_email

      configure_mail_connection
      @email = build_email
    end

    def send_email
      @email.deliver!
      puts "Email sent successfully to #{@to_email}"
    end

    private

    def configure_mail_connection
      Mail.defaults do
        delivery_method :smtp, {
          address: "smtp.gmail.com",
          port: 587,
          user_name: ENV["GMAIL_ACCOUNT"],
          password: ENV["GMAIL_PASSWORD"],
          authentication: :login,
          enable_starttls_auto: true
        }
      end
    end

    def build_email
      from_value = "#{@from_name} <#{ENV["GMAIL_ACCOUNT"]}>"
      to_value = "#{@to_name} <#{@to_email}>"
      subject_value = @subject
      body_value = Commonmarker.to_html("#{@body} \n\n--\n")
      cc_email = @cc_email
      bcc_email = @bcc_email

      if @signature
        body_value += @signature
      end

      Mail.new do
        from from_value
        to to_value
        subject subject_value
        content_type "text/html; charset=UTF-8"
        body body_value
        cc cc_email if cc_email
        bcc bcc_email if bcc_email
      end
    end
  end
end
