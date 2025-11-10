#!/usr/bin/env ruby

module PitchSlapped
  module Agent
    class Base
      attr_reader :response

      def initialize(
        industry:,
        prompt_path: "#{PitchSlapped::Utils.root_dir}/prompts/#{class_name_sanitized}.md",
        output_dir_path: "#{PitchSlapped::Utils.root_dir}/results/#{PitchSlapped::Utils.sanitize(industry)}",
        model: "google/gemini-2.5-pro"
      )
        RubyLLM.configure do |config|
          config.openrouter_api_key = ENV["OPENROUTER_API_KEY"]
          config.model_registry_file = "#{PitchSlapped::Utils.root_dir}/tmp/models_registry.json"
          config.log_file = "#{PitchSlapped::Utils.root_dir}/logs/ruby_llm.log"
          config.log_level = :debug
        end

        @chat = RubyLLM.chat(model:).with_schema(self.class.output_schema).with_temperature(0)
        @industry = industry
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
        final_output_path = File.join(@output_dir_path, "#{class_name_sanitized}_#{timestamp}.json")
        log "Saving response to #{final_output_path}"
        File.write(final_output_path, JSON.pretty_generate(@response))
      end

      private

      def output_schema
        self.class.const_get(:OutputSchema) if self.class.const_defined?(:OutputSchema)
      end

      def build_prompt
        @built_prompt ||=
          File.read(@prompt_path)
      end

      def log(message)
        File.open("#{PitchSlapped::Utils.root_dir}/logs/agents.log", "a") do |file|
          file.puts "[#{timestamp}] [#{self.class.name}] #{message}"
        end
      end

      def timestamp
        PitchSlapped::Utils.timestamp
      end

      def class_name_sanitized
        PitchSlapped::Utils.class_name_sanitized(self.class)
      end

      def book_title_sanitized
        PitchSlapped::Utils.sanitize(@book_title)
      end
    end
  end
end
