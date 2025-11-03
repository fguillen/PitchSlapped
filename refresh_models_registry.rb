require "ruby_llm"
require "dotenv/load"

RubyLLM.configure do |config|
  config.openrouter_api_key = ENV["OPENROUTER_API_KEY"]
  config.model_registry_file = "#{__dir__}/tmp/models_registry.json"
end

RubyLLM.models.refresh!
RubyLLM.models.save_to_json


puts RubyLLM.models
