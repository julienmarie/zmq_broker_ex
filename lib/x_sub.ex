defmodule ZmqBroker.XSub do
  use GenServer
  alias ZmqBroker.XPub


  def send(msg) do
    GenServer.cast({:global, :xsub}, {:message, msg})
  end

  def start_link(context) do
    GenServer.start_link(__MODULE__, context,  name: {:global, :xsub})
  end

  def init(context) do
    {:ok, xsub} = :erlzmq.socket(context, [:xsub, {:active, false}])
    :ok = :erlzmq.bind(xsub, 'tcp://*:5570')
    spawn fn -> loop(xsub) end
    {:ok, xsub }
  end

  def handle_cast({:message, msg}, state) do
    :erlzmq.send(state, msg)
    {:noreply, state}
  end


  def loop(state) do
    {:ok, msg} = :erlzmq.recv(state)
    XPub.send(msg)
    loop(state)
  end

  def terminate(_,_,state) do
    :erlzmq.close(state)
  end

end