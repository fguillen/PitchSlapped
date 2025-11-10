require_relative "base"

module PitchSlapped
  module Agent
    class CompaniesFinder < Base
      class OutputSchema < RubyLLM::Schema
        array :companies do
          object :company do
            any_of :name, description: "Name of the company" do
              string
              null
            end
            any_of :industry, description: "Industry the company operates in" do
              string
              null
            end
            any_of :headquarters, description: "Location of the company's headquarters" do
              string
              null
            end
            # any_of :overview, description: "Brief overview of the company" do
            #   string
            #   null
            # end
            # any_of :market_cap_eur, description: "Market capitalization of the company in EUR" do
            #   integer
            #   null
            # end
            # any_of :yoy_revenue_eur, description: "Year-over-year revenue of the company in EUR" do
            #   integer
            #   null
            # end
            any_of :linkedin_url, description: "URL to the company's LinkedIn profile" do
              string
              null
            end
          end
        end
      end

      def initialize(
        industry:,
        num_companies: 10,
        exclude_companies: [],
        model: "perplexity/sonar-pro-search"
      )
        super(model:, industry:)
        @industry = industry
        @num_companies = num_companies
        @exclude_companies = exclude_companies
      end

      def build_prompt
        @built_prompt ||=
          File.read(@prompt_path)
            .gsub("[INDUSTRY]", @industry)
            .gsub("[NUM_COMPANIES]", @num_companies.to_s)
            .gsub("[EXCLUDE_COMPANIES]", @exclude_companies.join(", "))
      end

      def self.output_schema
        OutputSchema
      end
    end
  end
end
