client<llm> GPT35Client {
  provider openai
  options {
    model "gpt-3.5-turbo"
    temperature 0
    api_key env.OPENAI_API_KEY
    max_tokens 200
  }
}

client<llm> GPT4Client {
  provider openai
  options {
    model "gpt-4"
    temperature 0
    api_key env.OPENAI_API_KEY
  }
}