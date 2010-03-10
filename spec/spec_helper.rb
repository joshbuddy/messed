ENV ||= 'test'

$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require File.join(File.dirname(__FILE__), '..', '.bundle', 'environment')

require 'logger'

LOGGER = Logger.new('test.log')

require 'messed'