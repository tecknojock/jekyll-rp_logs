module Jekyll
  module RpLogs

    class Fchat3Parser < RpLogs::Parser

      # Add this class tothe parsing dictionary
      FORMAT_STR = 'fchat3'
      RpLogGenerator.add self

      NICK = /(?<nick>[^:]{2,20})/
      DATE_REGEXP = /(?<timestamp>\[\d\d\d\d-\d\d-\d\d\ \d\d\:\d\d\])/
      TIMESTAMP_FORMAT = '[%Y-%m-%d %H:%M]'
      MSG = /(?<msg>[^\x00]*)/
      BAD_STUFF = /[^a-zA-Z\-\_ \s]/
      SPLITTER = /\n(?=#{FLAGS}#{DATE_REGEXP})/
      
      
      EMOTE = /^#{FLAGS}#{DATE_REGEXP} \*#{NICK}  #{MSG}$/m
      TEXT  = /^#{FLAGS}#{DATE_REGEXP} #{NICK}:  #{MSG}$/m
      
      
      
      def self.parse_line(line, options = {})
        # Careful, true will overwite local file specific options as well.
        strict_ooc = false 

        # Appends to the list. Use "-*Global*-" to indicate all.
        merge_text_into_rp = [] 
        splits_by_character = []

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
        sendername = $LAST_MATCH_INFO[:nick].gsub(BAD_STUFF, "")
 
       locoptions = {:strict_ooc => options[:strict_ooc] , :merge_text_into_rp => options[:merge_text_into_rp].clone , :splits_by_character => options[:splits_by_character].clone }
        if strict_ooc
          locoptions[:strict_ooc] =  strict_ooc
        end
        locoptions[:merge_text_into_rp] += merge_text_into_rp
        locoptions[:splits_by_character] += splits_by_character

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