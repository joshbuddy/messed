class Messed
  class Interface
    class Adapter
      class TwitterConsumer < Adapter
        
        attr_accessor :started_at, :packets_processed, :errors, :last_error, :last_ok, :last_status
        
        def init
          @started_at = Time.new
          @packets_processed = 0
          @errors = 0
          @last_error = nil
          @last_ok = nil
          @last_status = nil
        end

        def type
          :twitter
        end
        
        def status
          {
            :started_at => started_at,
            :packets_processed => packets_processed,
            :errors => errors,
            :last_error => last_error,
            :last_ok => last_ok,
            :last_status => last_status
          }
        end
        
      end
    end
  end
end