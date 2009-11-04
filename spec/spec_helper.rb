$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'logger'

LOGGER = Logger.new('test.log')

require 'messed'

