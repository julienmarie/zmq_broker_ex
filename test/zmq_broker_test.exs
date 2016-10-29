defmodule ZmqBrokerTest do
  use ExUnit.Case
  doctest ZmqBroker

 #   worker(ZmqBroker.Broker, [%{id: :fanout, context: context, in_port: 5570, out_port: 5571, in_socket: :xsub, out_socket: :xpub}], [id: :fanout, restart: :permanent]),
  #    worker(ZmqBroker.Broker, [%{id: :hello, context: context, in_port: 5572, out_port: 5573, in_socket: :pull, out_socket: :push}], [id: :hello, restart: :permanent]),
  #    

  test "pubsub" do
    message = "My test message"

    {:ok, ctx} = :erlzmq.context()
    #  Create a publisher.
    {:ok, pub} = :erlzmq.socket(ctx, [:pub, active: false])

    :ok = :erlzmq.connect(pub, 'tcp://127.0.0.1:31000')

    #  Create a subscriber.
    {:ok, sub} = :erlzmq.socket(ctx, [:sub, active: false])

    :ok = :erlzmq.connect(sub, 'tcp://127.0.0.1:31001')

    #  subscribe for all messages.
    :ok = :erlzmq.setsockopt(sub, :subscribe, "")

    :timer.sleep(1000)

    :ok = :erlzmq.send(pub, message)

    {:ok, message} = :erlzmq.recv(sub)

     :ok = :erlzmq.send(pub, message)

    {:ok, message} = :erlzmq.recv(sub)

     :ok = :erlzmq.send(pub, message)

    {:ok, message} = :erlzmq.recv(sub)

     :ok = :erlzmq.send(pub, message)

    {:ok, message} = :erlzmq.recv(sub)

    assert(message == message, "Message is different")
  end

  test "pushpull" do
    message = "My test message"

    {:ok, ctx} = :erlzmq.context()
    #  Create a publisher.
    {:ok, push} = :erlzmq.socket(ctx, [:push, active: false])

    :ok = :erlzmq.connect(push, 'tcp://127.0.0.1:31002')

    #  Create a subscriber.
    {:ok, pull} = :erlzmq.socket(ctx, [:pull, active: false])

    :ok = :erlzmq.connect(pull, 'tcp://127.0.0.1:31003')


    :timer.sleep(1000)

    :ok = :erlzmq.send(push, message)

    {:ok, message} = :erlzmq.recv(pull)

    :ok = :erlzmq.send(push, message)

    {:ok, message} = :erlzmq.recv(pull)

    assert(message == message, "Message is different")
  end

  test "reqrep" do
    message = "My Req Rep Test Message!"

    {:ok, ctx} = :erlzmq.context()
    #  Create a publisher.
    {:ok, req} = :erlzmq.socket(ctx, [:req, active: false])

    :ok = :erlzmq.connect(req, 'tcp://127.0.0.1:31004')

    #  Create a subscriber.
    {:ok, rep} = :erlzmq.socket(ctx, [:rep, active: false])

    :ok = :erlzmq.connect(rep, 'tcp://127.0.0.1:31005')

    :ok = :erlzmq.send(req, message)

    {:ok, newmessage} = :erlzmq.recv(rep)

    {:ok, 0} = :erlzmq.getsockopt(rep, :rcvmore)

    :ok = :erlzmq.send(rep, message)

     {:ok, newmessage} = :erlzmq.recv(req)

     :ok = :erlzmq.send(req, message)

    {:ok, newmessage} = :erlzmq.recv(rep)

    {:ok, 0} = :erlzmq.getsockopt(rep, :rcvmore)

    :ok = :erlzmq.send(rep, message)

     {:ok, newmessage} = :erlzmq.recv(req)


 

    assert(newmessage == message, "Message is different")
  end

  test "pushpull_with_schema" do
    message = "{
      \"address\": {
        \"streetAddress\": \"21 2nd Street\",
        \"city\": \"New York\"
      },
      \"phoneNumber\": [
        {
          \"location\": \"home\",
          \"code\": 44
        }
      ]
    }"

    {:ok, ctx} = :erlzmq.context()
    #  Create a publisher.
    {:ok, push} = :erlzmq.socket(ctx, [:push, active: false])

    :ok = :erlzmq.connect(push, 'tcp://127.0.0.1:31006')

    #  Create a subscriber.
    {:ok, pull} = :erlzmq.socket(ctx, [:pull, active: false])

    :ok = :erlzmq.connect(pull, 'tcp://127.0.0.1:31007')


    :timer.sleep(1000)

    :ok = :erlzmq.send(push, message)

    {:ok, message} = :erlzmq.recv(pull)

    :ok = :erlzmq.send(push, message)

    {:ok, message} = :erlzmq.recv(pull)

    assert(message == message, "Message is different")
  end

  test "pushpull_with_schema_and_wrong_data" do
    message = "{
      \"address\": {
        \"streetAddress\": \"21 2nd Street\",
        \"city\": \"New York\"
      },
      \"phoneNumber\": [
        {
          \"location\": \"home\",
          \"code\": \"Hello world\"
        }
      ]
    }"

    {:ok, ctx} = :erlzmq.context()
    #  Create a publisher.
    {:ok, push} = :erlzmq.socket(ctx, [:push, active: false])

    :ok = :erlzmq.connect(push, 'tcp://127.0.0.1:31006')

    #  Create a subscriber.
    {:ok, sub2} = :erlzmq.socket(ctx, [:sub, active: false])

    :ok = :erlzmq.connect(sub2, 'tcp://127.0.0.1:30052')

    :ok = :erlzmq.setsockopt(sub2, :subscribe, "Error")

    :timer.sleep(1000)

    :ok = :erlzmq.send(push, message)

    {:ok, error_message} = :erlzmq.recv(sub2)

    

    assert(String.starts_with?(error_message, "Error >> Message do not respect JSON Schema"), "Message is different")
  end


end
