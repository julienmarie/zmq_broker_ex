defmodule ApiTest do
  use ExUnit.Case
  doctest ZmqBroker

  use Maru.Test, for: ZmqBroker.Api

  test "/pubsub_test?type=pubsub&side=pub" do
    assert %{"your_port" => 31001} == get("/pubsub_test?type=pubsub&side=pub") |> json_response
  end

end