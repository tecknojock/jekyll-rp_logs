module Jekyll
  module RpLogs

    class SkypeParser < RpLogs::Parser

      # Add this class to the parsing dictionary
      FORMAT_STR = 'skype'
      RpLogGenerator.add self

      MODE = /([+%@&~!]?)/
      NICK = /(?<nick>[\w\-\\\[\]\{\}\^\`\|]+)/
      DATE_REGEXP = /(?<timestamp>\[\d\d?\/\d\d?\/\d\d\d\d \d\d?:\d\d:\d\d [AP]M)/
      TIMESTAMP_FORMAT = '[%m/%d/%Y %l:%M:%S %p'
      MSG = /(?<msg>[^\x00]*)/
      BAD_STUFF = /[^a-zA-Z\-\_ ]/
      SPLITTER = /\n(?=#{FLAGS}#{DATE_REGEXP})/

      JUNK =  /#{DATE_REGEXP}(?:\| .*?)?\] .* This message has been removed. .*$/ 
      EMOTE = /^#{FLAGS}#{DATE_REGEXP}(?: \| .*?)?\] \*\*\* #{NICK}\s*#{MSG}\s*(\*\*\*)?$/
      TEXT  = /^#{FLAGS}#{DATE_REGEXP}(?: \| .*?)?\] #{MODE}#{NICK}[^:]*?:\s*#{MSG}$/

      # Option Overwites. Careful, can overwite local file specific options as well. Uncomment what you need.
      # strict_ooc = True

      # Appends to the list. Use "-*Global*-" to indicate all.
      merge_test_into_rp = [] 
      splilts_by_character = []
      
      
      def self.parse_line(line, options = {})
        case line
        when EMOTE
          type = :rp
        when TEXT
          type = :ooc
        else
          # Only put text and emotes in the log
          return nil
        end 
        date = DateTime.strptime($LAST_MATCH_INFO[:timestamp], TIMESTAMP_FORMAT)
        contents = $LAST_MATCH_INFO[:msg]
        flags = $LAST_MATCH_INFO[:flags]
        sendername = $LAST_MATCH_INFO[:nick].tr(" ", "-").gsub(BAD_STUFF, "")

       locoptions = {:strict_ooc => options[:strict_ooc].clone , :merge_text_into_rp => options[:merge_text_into_rp].clone , :splilts_by_character => options[:splilts_by_character].clone }
        if strict_ooc
          locoptions[:strict_ooc] =  strict_ooc
        end
        locoptions[:merge_text_into_rp] += merge_text_into_rp
        locoptions[:splilts_by_character] += splilts_by_character

        LogLine.new(
          date,
          locoptions,
          sender: sendername,
          contents: contents,
          flags: flags,
          type: type
        ) 
      end 
    end  
  end
end