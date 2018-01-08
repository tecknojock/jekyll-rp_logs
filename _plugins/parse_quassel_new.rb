module Jekyll
  module RpLogs

    class QuasselnewParser < RpLogs::Parser

      # Add this class to the parsing dictionary
      FORMAT_STR = 'quassel-new'
      RpLogGenerator.add self

      MODE = /([+%@&~!]?)/
      NICK = /(?<nick>[\w\-\\\[\]\{\}\^\`\|]+)/
      DATE_REGEXP = /(?<timestamp>\[\d\d:\d\d:\d\d\] \[\d\d\.\d\d\.\d\d\])/
      TIMESTAMP_FORMAT = '[%H:%M:%S] [%d.%m.%y]'
      MSG = /(?<msg>[^\x00]*)/
      BAD_STUFF = /[^a-zA-Z\-\_ ]/
      SPLITTER = /\n(?=#{FLAGS}#{DATE_REGEXP})/

      JUNK =  /#{DATE_REGEXP}\t<?-?->?\t.*$/ 
      EMOTE = /^#{FLAGS}#{DATE_REGEXP} -\*- #{NICK}\s*#{MSG}$/
      TEXT  = /^#{FLAGS}#{DATE_REGEXP} <#{MODE}#{NICK}[^>]*>\s*#{MSG}$/

      # Option Overwites. Careful, can overwite local file specific options as well. Uncomment what you need.
      # Strict_ooc = True

      # Appends to the list. Use "-*Global*-" to indicate all.
      Merge_test_into_rp = [] 
      Splilts_by_character = []
      
      
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

        locoptions = {options[:strict_ooc].clone , options[:merge_text_into_rp].clone , options[:splilts_by_character].clone }
        if Strict_ooc
          locoptions[:strict_ooc] =  Strict_ooc
        end
        locoptions[:merge_text_into_rp] += Merge_text_into_rp
        locoptions[:splilts_by_character] += Splilts_by_character

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