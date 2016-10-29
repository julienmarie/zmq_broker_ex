ZmqBroker.Memory.channel(%{type: :pubsub, channel: "pubsub_test", side: :pub, in_schema: nil, out_schema: nil})
ZmqBroker.Memory.channel(%{type: :pushpull, channel: "pushpull_test", side: :push, in_schema: nil, out_schema: nil})
ZmqBroker.Memory.channel(%{type: :xreqxrep, channel: "reqrep_test", side: :xreq, in_schema: nil, out_schema: nil})
ZmqBroker.Memory.channel(%{type: :pushpull, channel: "pushpull_test_schema", side: :push, in_schema: "./test/test_schema.json", out_schema: nil})


ExUnit.start(timeout: 20000)
