#!/usr/bin/env ruby

require "ruby_llm"
require "ruby_llm/schema"
require "json"
require "dotenv/load"
require "debug"

module Agent
  class Base
    attr_reader :response

    def initialize(
      prompt_path:,
      output_dir_path: "#{__dir__}/../results",
      model: "google/gemini-2.5-pro"
    )
      RubyLLM.configure do |config|
        config.openrouter_api_key = ENV["OPENROUTER_API_KEY"]
        config.model_registry_file = "#{__dir__}/../tmp/models_registry.json"
        config.log_file = "#{File.dirname(__FILE__)}/../logs/ruby_llm.log"
        config.log_level = :debug
      end

      @chat = RubyLLM.chat(model:).with_schema(self.class.output_schema).with_temperature(0)
      @prompt_path = prompt_path
      @output_dir_path = output_dir_path
      @response = nil
    end

    def call
      log "Generating response"
      log build_prompt
      @response = @chat.ask(build_prompt).content
    end

    def save_response
      FileUtils.mkdir_p(@output_dir_path) unless Dir.exist?(@output_dir_path)
      final_output_path = File.join(@output_dir_path, "#{self.class.name.downcase}_#{timestamp}.json")
      log "Saving response to #{final_output_path}"
      File.write(final_output_path, JSON.pretty_generate(@response))
    end

    private

    def self.output_schema
      raise NotImplementedError, "Subclasses must implement the output_schema method"
    end

    def build_prompt
      @built_prompt ||=
        File.read(@prompt_path)
    end

    def log(message)
      File.open("#{File.dirname(__FILE__)}/../logs/agents.log", "a") do |file|
        file.puts "[#{timestamp}] [#{self.class.name}] #{message}"
      end
    end

    def timestamp
      Time.now.strftime("%Y%m%d_%H%M%S")
    end
  end
end
