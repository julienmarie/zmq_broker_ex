defmodule ZmqBroker.Broker do
  use GenServer

  def sendmsg(socket, msg, server, sendopt) do
    GenServer.cast({:global, server}, {:message, socket, msg, sendopt})
  end

  def start_link(config) do
    GenServer.start_link(__MODULE__, config,  name: {:global, config.id})
  end

  def init(config) do
    {:ok, in_socket} = :erlzmq.socket(config.context, [config.in_socket, {:active, false}])
    :ok = :erlzmq.bind(in_socket, "tcp://*:#{config.in_port}" |> String.to_charlist)
    {:ok, out_socket} = :erlzmq.socket(config.context, [config.out_socket, active: false])
    :ok = :erlzmq.bind(out_socket, "tcp://*:#{config.out_port}" |> String.to_charlist)
    inschema = resolve_schema(config.in_schema)
    outschema = resolve_schema(config.out_schema)
    spawn fn -> loop(in_socket, out_socket, config.id, inschema) end
    case config.out_socket do
      :xpub -> spawn fn -> loop(out_socket, in_socket, config.id, outschema) end
      :xreq -> spawn fn -> loop(out_socket, in_socket, config.id, outschema) end
      _ -> :ok
    end
    {:ok, %{in_socket: in_socket, out_socket: out_socket }}
  end

  def handle_cast({:message, socket, msg, sendopt}, state) do
    case sendopt do
      nil -> :erlzmq.send(socket, msg)
      :sndmore -> :erlzmq.send(socket, msg, [:sndmore])
      _ -> :erlzmq.send(socket, msg)
    end
    
    {:noreply, state}
  end

  def loop(socket, othersocket, server, schema) do
    {:ok, msg} = :erlzmq.recv(socket)
    sendopt = case :erlzmq.getsockopt(socket, :rcvmore) do
      {:ok, 0} -> nil
      {:ok, _} -> :sndmore
    end
    case schema do

      nil -> 
        sendmsg(othersocket, msg, server, sendopt)
      _ -> 
        case ExJsonSchema.Validator.valid?(schema, Poison.decode!(msg)) do
        true -> sendmsg(othersocket, msg, server, sendopt)
        _ -> 
          ZmqBroker.Events.send_evt("Error >> Message do not respect JSON Schema >> #{msg}")
          :ok
      end
    end
    
    loop(socket, othersocket, server, schema)
  end


  def resolve_schema(schemapath) do
    schema = case schemapath do 
      nil -> nil
      _ -> 
        case validate_uri(schemapath) do
          {:ok, uri} -> HTTPoison.get!(uri).body |> Poison.decode! |> ExJsonSchema.Schema.resolve
          _ ->  case File.read(schemapath) do 
                  {:ok, content} -> Poison.decode!(content) |> ExJsonSchema.Schema.resolve
                  _ -> nil
                end
        end
    end
    schema
  end

  def validate_uri(str) do
    uri = URI.parse(str)
    case uri do
      %URI{scheme: nil} -> {:error, uri}
      %URI{host: nil} -> {:error, uri}
      %URI{path: nil} -> {:error, uri}
      uri -> {:ok, uri}
    end 
  end 

  def terminate(_,_,state) do
    :erlzmq.close(state)
  end

end