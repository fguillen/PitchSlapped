#!/usr/bin/env ruby

require "ruby_llm"
require "ruby_llm/schema"
require "json"
require "dotenv/load"
require "debug"

class Generator
  def initialize(prompt_path:, output_dir_path:, model: "google/gemini-2.5-pro")
    RubyLLM.configure do |config|
      config.openrouter_api_key = ENV["OPENROUTER_API_KEY"]
      config.model_registry_file = "#{__dir__}/tmp/models_registry.json"
      config.log_file = "#{File.dirname(__FILE__)}/logs/ruby_llm.log"
      config.log_level = :debug
    end

    @chat = RubyLLM.chat(model:).with_schema(self.class.output_schema).with_temperature(0)
    @prompt_path = prompt_path
    @output_dir_path = output_dir_path
  end

  def completion
    puts "Generating completion"
    puts build_prompt
    result = @chat.ask(build_prompt)
    save_completion(result.content)
  end

  private

  def self.output_schema
    raise NotImplementedError, "Subclasses must implement the output_schema method"
  end

  def build_prompt
    @prompt
  end

  def save_completion(content)
    Dir.mkdir(@output_dir_path) unless Dir.exist?(@output_dir_path)
    final_output_path = File.join(@output_dir_path, "#{self.class.name.downcase}_#{Time.now.to_i}.json")
    puts "Saving completion to #{final_output_path}"
    File.write(final_output_path, JSON.pretty_generate(content))
  end
end
