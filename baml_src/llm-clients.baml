client<llm> GPT5MiniClient {
  provider openai
  options {
    model "gpt-5-mini"
    api_key env.OPENAI_API_KEY
    max_tokens 200
  }
}

client<llm> GPT5Client {
  provider openai
  options {
    model "gpt-5"
    api_key env.OPENAI_API_KEY
  }
}