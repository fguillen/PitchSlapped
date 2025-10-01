# Email Generator with RubyLLM

This script generates personalized intro emails using the RubyLLM gem and data from a CSV file.

## Features

- Reads contact information from CSV files
- Uses RubyLLM to generate personalized emails with AI
- Supports OpenAI, Anthropic, and other LLM providers
- Outputs formatted markdown files with generated emails
- Built-in error handling and validation

## Prerequisites

- Ruby (version 2.7 or higher)
- An API key for one of the supported LLM providers:
  - OpenAI API key (starts with `sk-`)
  - Anthropic API key (starts with `sk-ant-`)
  - Or other supported providers

## Installation

The script uses bundler/inline to manage dependencies automatically. No separate Gemfile installation needed.

## Setup

1. **Set your API key** as an environment variable:
   ```bash
   export OPENAI_API_KEY="your-openai-api-key"
   # OR
   export ANTHROPIC_API_KEY="your-anthropic-api-key"
   ```

2. **Prepare your CSV file** with the following columns:
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
- Input: `contacts.csv`
- Output: `generated_emails.md`
- Prompt: `prompt.md`

### Custom Files
```bash
ruby email_generator.rb my_contacts.csv my_output.md
```

### Example CSV Format
```csv
company_name,industry,contact_name,contact_linkedin
"Airbus Defence and Space","Aerospace & Defense","Sarah Johnson","https://linkedin.com/in/sarah-johnson-airbus"
"Planet Labs","Earth Observation","Michael Chen","https://linkedin.com/in/michael-chen-planet"
```

## Output Format

The script now requests structured JSON responses from the LLM and generates a markdown file with the following structure for each contact:

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

### JSON Structure
The LLM is instructed to return data in this JSON format:
```json
{
  "company_name": "Company Name",
  "industry": "Industry Sector",
  "contact_name": "Contact Person",
  "contact_linkedin": "LinkedIn URL",
  "inferred_email": "generated.email@company.com",
  "subject": "Email Subject Line",
  "body": "Complete email body text"
}
```

## Configuration

The script automatically detects your API provider based on the key format:
- Keys starting with `sk-` are treated as OpenAI keys
- Keys starting with `sk-ant-` are treated as Anthropic keys
- Other formats default to OpenAI

## Error Handling

The script includes comprehensive error handling:
- Validates file existence before processing
- Checks for required CSV columns
- Handles API errors gracefully
- Provides detailed success/error summaries

## Troubleshooting

1. **"API key not found"**: Make sure you've set one of the environment variables
2. **"CSV file not found"**: Check that your CSV file exists and the path is correct
3. **"Missing placeholders"**: Ensure your `prompt.md` contains the required placeholders
4. **API errors**: Check your API key and account balance

## Sample Files

- `contacts.csv`: Sample CSV with test data
- `prompt.md`: Template prompt for email generation
- `email_generator.rb`: Main script

## License

MIT License
