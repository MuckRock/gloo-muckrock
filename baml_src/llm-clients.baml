client<llm> GPT61TerraClient {
  provider openai
  options {
    model "gpt-6.1-terra"
    api_key env.OPENAI_API_KEY
    max_tokens 200
  }
}

client<llm> GPT61SolClient {
  provider openai
  options {
    model "gpt-6.1-sol"
    api_key env.OPENAI_API_KEY
  }
}