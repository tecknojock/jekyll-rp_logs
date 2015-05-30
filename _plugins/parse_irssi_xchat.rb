require_relative "rp_log_converter"
require_relative "rp_parser"

module RpLogs

  class IrssiXChatParser < RpLogs::Parser

    # Add this class to the parsing dictionary
    FORMAT_STR = 'irssi-xchat'
    RpLogGenerator.add self

    # Stuff
    class << self
      MODE = /([+%@&~!]?)/
      NICK = /([\w\-\\\[\]\{\}\^\`\|]+)/
      DATE_REGEXP = /(\d\d:\d\d)/

      FLAGS = /((?:![A-Z]+ )*)/
      # TODO: Update to match join/part/quit format
      JUNK =  /#{DATE_REGEXP}\t<?-->?\t.*$/ 
      EMOTE = /^#{FLAGS}#{DATE_REGEXP} {16}\* \| #{NICK}\s+([^\n]*)$/
      TEXT  = /^#{FLAGS}#{DATE_REGEXP} < *#{MODE}#{NICK}> \| ([^\n]*)$/

      TIMESTAMP_FORMAT = '%H:%M'

      def parse_line(line, options = {}) 
        case line
        when JUNK
          nil
        when EMOTE
          date = DateTime.strptime($2, TIMESTAMP_FORMAT)
          Parser::LogLine.new(date, options, sender: $3, contents: $4, \
            flags: $1, type: :rp)
        when TEXT
          date = DateTime.strptime($2, TIMESTAMP_FORMAT)
          mode = if $3 != '' then $3 else ' ' end
          Parser::LogLine.new(date, options, sender: $4, contents: $5, \
            flags: $1, type: :ooc, mode: mode)
        else
          # Only put text and emotes in the log
          nil
        end
      end
    end

  end  

end
