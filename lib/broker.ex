defmodule ZmqBroker.Broker do
  use GenServer

  def sendmsg(socket, msg, server) do
    GenServer.cast({:global, server}, {:message, socket, msg})
  end

  def start_link(config) do
    GenServer.start_link(__MODULE__, config,  name: {:global, config.id})
  end

  def init(config) do
    {:ok, in_socket} = :erlzmq.socket(config.context, [config.in_socket, {:active, false}])
    :ok = :erlzmq.bind(in_socket, "tcp://*:#{config.in_port}" |> String.to_charlist)
    {:ok, out_socket} = :erlzmq.socket(config.context, [config.out_socket, active: false])
    :ok = :erlzmq.bind(out_socket, "tcp://*:#{config.out_port}" |> String.to_charlist)
    spawn fn -> loop(in_socket, out_socket, config.id) end
    case config.out_socket do
      :xpub -> spawn fn -> loop(out_socket, in_socket, config.id) end
      _ -> :ok
    end
    {:ok, %{in_socket: in_socket, out_socket: out_socket }}
  end

  def handle_cast({:message, socket, msg}, state) do
    :erlzmq.send(socket, msg)
    {:noreply, state}
  end

  def loop(socket, othersocket, server) do
    {:ok, msg} = :erlzmq.recv(socket)
    sendmsg(othersocket, msg, server)
    loop(socket, othersocket, server)
  end

  def terminate(_,_,state) do
    :erlzmq.close(state)
  end

end