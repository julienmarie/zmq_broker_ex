defmodule ZmqBroker.XPub do
  use GenServer
  alias ZmqBroker.XSub

  def send(msg) do
    GenServer.cast({:global, :xpub}, {:message, msg})
  end

  def start_link(context) do
    GenServer.start_link(__MODULE__, context,  name: {:global, :xpub})
  end

  def init(context) do
    {:ok, xpub} = :erlzmq.socket(context, [:xpub, active: false])
    :ok = :erlzmq.bind(xpub, 'tcp://127.0.0.1:5571')
    spawn fn -> loop(xpub) end
    {:ok, xpub}
  end

  def handle_cast({:message, msg}, state) do
    :erlzmq.send(state, msg)
    {:noreply, state}
  end

  def loop(state) do
    {:ok, msg} = :erlzmq.recv(state)
    XSub.send(msg)
    loop(state)
  end

  def terminate(_,_,state) do
    :erlzmq.close(state)
  end

end