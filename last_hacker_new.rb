#!/usr/bin/env ruby

require_relative "generator"

class LastHackerNewGenerator < Generator
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
  generator =
    LastHackerNewGenerator.new(
      prompt_path: "#{__dir__}/prompts/last_hacker_new.md"
    )
  generator.completion
end

if __FILE__ == $0
  main
end
