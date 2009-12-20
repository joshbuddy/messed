queues.incoming.host = '127.0.0.1'
queues.incoming.port = 11300
queues.incoming.tube = 'incoming-tube'

queues.outgoing.host = '127.0.0.1'
queues.outgoing.port = 11300
queues.outgoing.tube = 'outgoing-tube'

interfaces.twitter_sender.adapter = :twitter_sender
interfaces.twitter_sender.options[:username] = 'josh'
interfaces.twitter_sender.options[:password] = 'josh'
