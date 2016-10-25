defmodule ZmqBrokerTest do
  use ExUnit.Case
  doctest ZmqBroker

  test "connect" do
    message = "This is a big big big big big big message This is a big big big big big 
    big message This is a big big big big big big message This is a big big big big 
    big big message This is a big big big big big big message This is a big big big 
    big big big message This is a big big big big big big message This is a big big big big big big message This is a big big big big big big message This is a big big big big big big message This is a big big big big big big message This is a big big big big big big message This is a big big big big big big message This is a big big big big big big message This is a big big big big big big message This is a big big big big big big message This is a big big big big big big message This is a big big big big big big message 
    This is a big big big big big big message This is a big big big big big big message 
    This is a big big big big big big message This is a big big big big big big message 
    This is a big big big big big big message This is a big big big big big big message 
    This is a big big big big big big message This is a big big big big big big message
     This is a big big big big big big message This is a big big big big big big message
     This is a big big big big big big message This is a big big big big big big message T
     his is a big big big big big big message This is a big big big big big big message
      This is a big big big big big big message This is a big big big big big big message
       This is a big big big big big big message This is a big big big big big big message 
       This is a big big big big big big message This is a big big big 

    big big big message This is a big big big big big big message 

    This is a big big big big big big message This is a big big big big 

    big big message This is a big big big big big big message This is a 


    big big big big big big message This is a big big big big big big message This is a big
     big big big big big message This is a big big big big big big message This is a big big 
     big big big big message This is a big big big big big big message This is a big big big
      big big big message This is a big big big big big big message This is a big big big big
       big big message This is a big big big big big big message This is a big big big big
        big big message This is


     a big big big big big big message This is a big big big big big big 
     message This is a big big big big big big message This is a big big big 
     big big big message This is a big big big big big big message This is a big 
     big big big big big message This is a big big big big big big message This is a 
     big big big big big big message This is a big big big big big big message This is a 
     big big big big big big message This is a big big big big big big message This is a big 
     big big big big big message This is a big big big big big big message This is a big big
      big big big big message This is a big big big big big big message This is a big big big
       big big big message This is a big big big big big big message This is a big big big 
       big big big message This is a big big big big big big message This is a big big big 
       big big big message This is a big big big big big big message This is a big big big
        big big big message This is a big big big big big big message This is a big big 
        big big big big message"
     {:ok, ctx} = :erlzmq.context()
    #  Create a publisher.
    {:ok, pub} = :erlzmq.socket(ctx, [:pub, active: false])

    :ok = :erlzmq.connect(pub, 'tcp://127.0.0.1:5570')

    #  Create a subscriber.
    {:ok, sub} = :erlzmq.socket(ctx, [:sub, active: false])

    :ok = :erlzmq.connect(sub, 'tcp://127.0.0.1:5571')

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

    assert(message = message, "Message is different")
  end
end
