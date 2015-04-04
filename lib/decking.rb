require 'hashie'
require 'docker'
Docker.validate_version!
require "ruby-progressbar"
require 'thread'
require 'yaml'

require 'log4r'
require 'log4r/formatter/patternformatter'
require 'log4r/outputter/syslogoutputter'
require 'syslog'
include Syslog::Constants

Log4r::Logger.global.level = Log4r::ALL
Log4r::StdoutOutputter.new('stdout', formatter: Log4r::PatternFormatter.new( pattern: '%d (%C) %l: %m', date_pattern: '%FT%T%:z' ))
Log4r::SyslogOutputter.new('decking', logopt: LOG_CONS | LOG_PID , facility: LOG_USER, formatter: Log4r::PatternFormatter.new( date_method: 'usec', pattern: '(%C} %l: %m'))
Log4r::Logger.new('decking')
Log4r::Logger['decking'].add('decking')
Log4r::Logger['decking'].add('stdout')
Log4r::Logger['decking'].debug "Initialized #{__FILE__}"

require_relative "decking/version"
require_relative "decking/helpers"
require_relative "decking/parser"
require_relative "decking/containers"
