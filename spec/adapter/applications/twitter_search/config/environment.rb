queues.incoming.host = '127.0.0.1'
queues.incoming.port = 11300
queues.incoming.tube = 'incoming-tube'

queues.outgoing.host = '127.0.0.1'
queues.outgoing.port = 11300
queues.outgoing.tube = 'outgoing-tube'

interfaces.search.adapter = :twitter_search
interfaces.search.options[:fetch] = {:query => {'q' => 'love'}, :host => 'search.twitter.com', :path => 'search.json'}
interfaces.search.options[:interval] = 30
