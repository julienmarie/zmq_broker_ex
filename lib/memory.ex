defmodule ZmqBroker.Memory do
  use GenServer
  import Supervisor.Spec


  def channel(params) do
    GenServer.call(:memory, {:channel, params})
  end

  def list() do
    GenServer.call(:memory, {:list})
  end

  def start_link(initial_port) do
    GenServer.start_link(__MODULE__, initial_port, name: :memory)
  end

  def init(initial_port) do
    {:ok, context} = :erlzmq.context()
    spawn fn() -> Supervisor.start_child(ZmqBroker.Supervisor, worker(ZmqBroker.Events, [context], [id: :event_dispatcher, restart: :permanent])) end
    {:ok, %{cursor: initial_port, brokers: [], context: context}}
  end

  def handle_call({:channel, params}, _from, state) do
    {new_state, port} = case Enum.find(state.brokers, fn(x) -> x.id == params.channel end) do
      nil -> create_broker(params, state)
      broker -> {state, get_port(broker, params.side)}
    end
    {:reply, port, new_state}
  end

  def handle_call({:list}, _from, state) do
    {:reply, state.brokers, state}
  end

  def get_port(broker, side) do
    case side do
      :xsub -> broker.in_port
      :sub -> broker.in_port
      :pull -> broker.in_port
      :rep -> broker.in_port
      :xrep -> broker.in_port
      :xpub -> broker.out_port
      :pub -> broker.out_port
      :push -> broker.out_port
      :req -> broker.out_port
      :xreq -> broker.out_port
    end
  end

  def create_broker(params, state) do
    in_port = state.cursor
    out_port = state.cursor + 1
    sockets = case params.type do
      :pubsub -> %{in_socket: :xsub, out_socket: :xpub}
      :xpubxsub -> %{in_socket: :xsub, out_socket: :xpub}
      :pushpull -> %{in_socket: :pull, out_socket: :push}
      :reqrep -> %{in_socket: :xrep, out_socket: :xreq}
      :xreqxrep -> %{in_socket: :xrep, out_socket: :xreq}
    end 
    config = %{
      id: params.channel, 
      context: state.context, 
      in_port: in_port, 
      out_port: out_port, 
      in_socket: sockets.in_socket,
      out_socket: sockets.out_socket,
      in_schema: params.in_schema,
      out_schema: params.out_schema
    }
    {:ok, _} = Supervisor.start_child(ZmqBroker.Supervisor, worker(ZmqBroker.Broker, [config], [id: params.channel, restart: :permanent]))
    {%{cursor: out_port + 1, brokers: [config|state.brokers], context: state.context}, get_port(config, params.side)}
  end
end