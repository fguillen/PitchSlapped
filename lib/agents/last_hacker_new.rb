#!/usr/bin/env ruby

require_relative "base"

module Agent
  class LastHackerNewGenerator < Base
    class OutputSchema < RubyLLM::Schema
      string :title, description: "Title of the news article"
      string :link, description: "Link to the Hacker News comments"
    end

    def initialize(prompt_path:, output_dir_path: "results", model: "perplexity/sonar-pro-search")
      super(prompt_path:, output_dir_path:, model:)
    end

    def build_prompt
      @prompt = File.read(@prompt_path)
      @prompt
    end

    def self.output_schema
      OutputSchema
    end
  end

  # Main execution
  def main
    agent =
      LastHackerNewGenerator.new(
        prompt_path: "#{PitchSlapped::Utils.root_dir}/prompts/last_hacker_new.md"
      )
    agent.completion
  end

  if __FILE__ == $0
    main
  end
end
