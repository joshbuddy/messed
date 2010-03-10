class Messed
  class Interface
    class Adapter
      class SMS
        class Textmarks < SMSHTTPReceiver
          
          def receive(request, message)
            message.from  = request.params['from']
            message.to    = request.params['to']
            message.body  = request.params['body']
          end
          
        end
      end
    end
  end
end