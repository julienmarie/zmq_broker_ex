# ZmqBroker

This is a general broker for ZeroMQ with optional contract checking via json schemas.
It allows to create "channels" on the fly via a rest API.
It supports PUB/SUB (XPUB/XSUB), PULL/PUSH, REQ/REP (DEALER/ROUTER) brokerage.
Also it 

# API

By default the REST API listens to the port 30050

## Create / get port of channel

To create a channel or get the port you should connect to, call :

```
/:channel_name?type=:type&side=:side&in_schema=:in_schema&out_schema=:out_schema
```

The parameters are :

- `:channel_name` : the name of the channel
- `:type` : can be pubsub, reqrep, pullpush
- `:side` : which side is calling ( pub or sub? req or rep? pull or push?)
- `:in_schema` (optional) : the url or path to the json schema file to validate message going from sender to receiver
- `:out_schema` (optional) : the url or path to the json schema file to validate replies - only for rep

The answer will be 

```
  { your_port: :port_number }
```

Where the broker gives you which port you should connect to. 

The ports are creating starting from initial port in config, default is 31000

## Get the list of the channels

```
/list
```

Gives you a list of all the channels with their configuration.


## Event Pub Sub Channel

There is a PUB SUB Channel for event broadcasting set up by default on ports 30051 for sub and 30052 for pub. JSON Schema validation errors are broadcasted here. You can publish other events via this channel if you need.

# Dockerfile

Dockerfile included, just pull the image producture/zmqbroker to get started quickly.



