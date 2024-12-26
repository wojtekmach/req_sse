# ReqSSE

WIP SSE support for Req.

## Usage

```elixir
Mix.install([{:req_sse, github: "wojtekmach/req_sse"}])

Req.post!(
  "https://api.anthropic.com/v1/messages",
  headers: [
    anthropic_version: "2023-06-01",
    x_api_key: System.fetch_env!("CLAUDE_API_KEY")
  ],
  json: %{
    model: "claude-3-5-sonnet-20241022",
    max_tokens: 1024,
    messages: [%{role: "user", content: "What is 1 + 2?"}],
    stream: true
  },
  plugins: [ReqSSE],
  sse: [
    events: fn events, {req, resp} ->
      for event <- events, event.event == "content_block_delta" do
        IO.inspect(JSON.decode!(event.data))
      end

      {:cont, {req, resp}}
    end
  ]
)
```

## License

Copyright (c) 2024 Wojtek Mach

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at [http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
