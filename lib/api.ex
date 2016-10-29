defmodule ZmqBroker.Api do
    use Maru.Router

  





    #namespace :api do
    get "/list" do
        json(conn, %{brokers: ZmqBroker.Memory.list()})
      end
    
      route_param :channel do
        plug ZmqBroker.ZmqPlug
        desc "Get or create channel info"
        params do
          requires :type,    type: Atom, values: [:pubsub, :xpubxsub, :pushpull, :reqrep], default: :pushpull
          requires :side,    type: Atom, values: [:pub, :sub, :xpub, :xsub, :push, :pull, :req, :rep], default: :pull
          optional :in_schema,  type: String, default: nil
          optional :out_schema,  type: String, default: nil
        end
        get do
          port = ZmqBroker.Memory.channel(
            %{
              type: params[:type], 
              channel: params[:channel], 
              side: params[:side], 
              in_schema: params[:in_schema],
              out_schema: params[:out_schema]
            }
          )
          json(conn, %{your_port: port})
        end
        
      end

      
    #end
  end