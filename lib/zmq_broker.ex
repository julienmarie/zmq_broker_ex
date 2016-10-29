defmodule ZmqBroker do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
        

    import Supervisor.Spec, warn: false

    # Define workers and child supervisors to be supervised
    children = [
      worker(ZmqBroker.Memory, [Application.get_env(:zmq_broker, :initial_port)], [])
    ]



    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ZmqBroker.Supervisor]
    Supervisor.start_link(children, opts)
  end



end
