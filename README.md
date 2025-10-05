# Email Generator with RubyLLM

This script generates personalized intro emails using the RubyLLM gem and data from a CSV file.

## Features

- Reads contact information from CSV files
- Uses RubyLLM to generate personalized emails with AI
- Supports OpenAI, Anthropic, and other LLM providers
- Outputs formatted markdown file with generated emails

## Prerequisites

- Ruby (version 2.7 or higher)
- An API key for OpenRouter

## Installation

The script uses bundler/inline to manage dependencies automatically. No separate Gemfile installation needed.

## Setup

1. **Set your OpenRouter API key** on the `.env` file:
   ```
   #.env
   OPEN_ROUTER_API_KEY="your-openrouter-api-key"
   ```

2. **Prepare your CSV file** in the path `data/contacts.csv` with the following columns:
   - `company_name`: Name of the company
   - `industry`: Industry/sector of the company
   - `contact_name`: Name of the contact person
   - `contact_linkedin`: LinkedIn profile URL

3. **Customize the prompt** in `prompt.md` to match your needs

## Usage

### Basic Usage
```bash
ruby email_generator.rb
```
This will use the default files:
- Input: `data/contacts.csv`
- Output: `data/generated_emails_TIMESTAMP.md`
- Prompt: `prompt.md`

### Example CSV Format
```csv
company_name,industry,contact_name,contact_linkedin
"Airbus Defence and Space","Aerospace & Defense","Sarah Johnson","https://linkedin.com/in/sarah-johnson-airbus"
"Planet Labs","Earth Observation","Michael Chen","https://linkedin.com/in/michael-chen-planet"
```

## Output Format

```markdown
# Email to: [Contact Name]

- **Company:** [Company Name]
- **Industry:** [Industry]
- **Contact:** [Contact Name]
- **LinkedIn:** [LinkedIn URL]
- **Inferred Email:** [Generated Email Address]

## [Email Subject]

[Email Body]

---
```

## License

MIT License
