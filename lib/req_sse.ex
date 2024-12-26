defmodule ReqSSE do
  def attach(req) do
    req
    |> Req.Request.register_options([:sse])
    |> Req.Request.append_request_steps(sse: &handle_sse/1)
  end

  defp handle_sse(req) do
    if sse = req.options[:sse] do
      send_events = Keyword.fetch!(sse, :events)

      Req.merge(req,
        into: fn {:data, data}, {req, resp} ->
          if sse?(resp) do
            buffer = Req.Request.get_private(req, :sse_buffer, "")
            {events, buffer} = ServerSentEvents.parse(buffer <> data)
            req = Req.Request.put_private(req, :sse_buffer, buffer)

            if events != [] do
              send_events.(events, {req, resp})
            else
              {:cont, {req, resp}}
            end
          else
            if into = req.options[:into] do
              into.({:data, data}, {req, resp})
            else
              {:cont, {req, update_in(resp.body, &(data <> &1))}}
            end
          end
        end
      )
    else
      req
    end
  end

  defp sse?(resp) do
    case Process.get(:req_sse) do
      nil ->
        sse? = match?(["text/event-stream" <> _ | _], resp.headers["content-type"])
        Process.put(:req_sse, sse?)
        sse?

      sse? ->
        sse?
    end
  end
end
