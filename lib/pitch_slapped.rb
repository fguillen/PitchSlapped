require "ruby_llm"
require "ruby_llm/schema"
require "json"
require "date"
require "dotenv/load"
require "debug"
require "commonmarker"

require_relative "utils"
require_relative "agents/base"
require_relative "agents/companies_finder"
require_relative "agents/company_contacts_finder"
require_relative "agents/email_copywriter"

require_relative "orchestrator"
require_relative "email_sender"
require_relative "postman"

module PitchSlapped
  VERSION = "0.1.0"
end
