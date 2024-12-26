defmodule ReqSSETest do
  use ExUnit.Case, async: true

  test "it works", %{test_pid: pid} do
    Req.get(
      plug: fn conn ->
        conn =
          conn
          |> Plug.Conn.put_resp_content_type("text/event-stream")
          |> Plug.Conn.send_chunked(200)

        {:ok, conn} = Plug.Conn.chunk(conn, "event: 1\ndata: 1\n\n")
        {:ok, conn} = Plug.Conn.chunk(conn, "event: 2\ndata: 2\n\n")
        conn
      end,
      plugins: [ReqSSE],
      sse: [
        events: fn events, {req, resp} ->
          for event <- events, do: send(pid, event)
          {:cont, {req, resp}}
        end
      ]
    )

    assert_received %{event: "1", data: "1"}
    assert_received %{event: "2", data: "2"}
    refute_received _
  end
end
