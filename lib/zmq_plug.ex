defmodule ZmqBroker.ZmqPlug do
  use Maru.Middleware



  def call(conn, _opts) do
    Plug.Conn.fetch_query_params conn, []
  end
end