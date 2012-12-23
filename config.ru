$LOAD_PATH.unshift(File.dirname(__FILE__))
Bundler.setup
require 'irc_logger/viewer'

run IrcLogger::Viewer
