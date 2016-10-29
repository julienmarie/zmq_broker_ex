defmodule ZmqBroker.Events do
  use GenServer

  def send_evt(msg) do
    GenServer.cast(:events_dispatcher, {:event, msg, nil})
  end

  def send_evt(topic, msg) do
    GenServer.cast(:events_dispatcher, {:event, "#{topic} #{msg}", nil})
  end

  def send_evt(topic, msg, sendopt) do
    GenServer.cast(:events_dispatcher, {:event, "#{topic} #{msg}", sendopt})
  end

  def start_link(context) do
    GenServer.start_link(__MODULE__, context, name: :events_dispatcher)
  end

  def init(context) do
    {:ok, pub} = :erlzmq.socket(context, [:pub, {:active, false}])
    {:ok, sub} = :erlzmq.socket(context, [:sub, {:active, false}])
    port_sub = Application.get_env(:zmq_broker, :events_port_sub)
    port_pub = Application.get_env(:zmq_broker, :events_port_pub)
    :ok = :erlzmq.bind(sub, "tcp://*:#{port_sub}" |> String.to_charlist)
    :ok = :erlzmq.bind(pub, "tcp://*:#{port_pub}" |> String.to_charlist)
    spawn fn -> loop(sub) end
    {:ok, %{pub: pub, sub: sub}}
  end

  def handle_cast({:event, msg, sendopt}, socket) do
    case sendopt do
      nil -> :erlzmq.send(socket.pub, msg)
      :sndmore -> :erlzmq.send(socket, msg, [:sndmore])
      _ -> :erlzmq.send(socket, msg)
    end
    {:noreply, socket}
  end

  def loop(sub) do
    {:ok, msg} = :erlzmq.recv(sub)
    case :erlzmq.getsockopt(sub, :rcvmore) do
      {:ok, 0} -> send_evt(msg, nil)
      {:ok, _} -> send_evt(msg, :sndmore)
    end
  end


end