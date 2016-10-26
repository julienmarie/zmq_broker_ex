defmodule ZmqBroker do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
        {:ok, context} = :erlzmq.context()

    import Supervisor.Spec, warn: false

    # Define workers and child supervisors to be supervised
    children = [
      worker(ZmqBroker.Broker, [%{id: :fanout, context: context, in_port: 5570, out_port: 5571, in_socket: :xsub, out_socket: :xpub}], [id: :fanout, restart: :permanent]),
      worker(ZmqBroker.Broker, [%{id: :hello, context: context, in_port: 5572, out_port: 5573, in_socket: :pull, out_socket: :push}], [id: :hello, restart: :permanent]),

    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ZmqBroker.Supervisor]
    Supervisor.start_link(children, opts)
  end

end
