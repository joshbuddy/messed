class Messed
  class Interface
    class Adapter
      class SMS
        
        class Carrier
          # Looks up a carrier from our carrier symbols
          def self.find sym
            mapping[sym.to_sym]
          end
          
          # List of carriers TODO probably should live in the config and be back-endable
          def self.mapping
            {
              :att      => 'AT&T Wirless',
              :verizon  => 'Verizon Wireless',
              :t_mobile => 'T Mobile',
              :boost    => 'Boost Mobile',
              :sprint   => 'Sprint',
              :virgin   => 'Virgin Mobile'
            }
          end
        end
        
      end
    end
  end
end