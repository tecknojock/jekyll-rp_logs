require_relative "rp_tags"
require_relative "rp_parser"

module RpLogs

  class RpLogGenerator < Jekyll::Generator
    safe true
    priority :normal

    @@parsers = {}

    def RpLogGenerator.add(parser) 
      @@parsers[parser::FORMAT_STR] = parser
    end

    def initialize(config)
      config['rp_convert'] ||= true
    end

    def generate(site)
      return unless site.config['rp_convert']
      @site = site

      # Directory of RPs
      index = site.pages.detect { |page| page.data['rp_index'] }
      index.data['rps'] = {'canon' => [], 'noncanon' => []}

      # Convert all of the posts to be pretty
      # Also build up our hash of tags
      site.pages.select { |p| p.data['layout'] == 'rp' }
        .each { |page|
          # puts page.inspect
          page.data['rp_tags'] = page.data['rp_tags'].split(',').map { |t| Tag.new t }.sort
          
          convertRp page

          key = if page.data['canon'] then 'canon' else 'noncanon' end
          index.data['rps'][key].push page
        }

      index.data['rps']['canon'].sort_by! { |p| p.data['start_date'] }.reverse!
      index.data['rps']['noncanon'].sort_by! { |p| p.data['start_date'] }.reverse!
    end

    def convertRp(page)
      options = get_options page

      compiled_lines = []
      page.content.each_line { |raw_line| 
        page.data['format'].each { |format| 
          log_line = @@parsers[format].parse_line(raw_line, options)
          if log_line then
            compiled_lines << log_line 
            break
          end
        }
      }

      merge_lines! compiled_lines
      stats = extract_stats compiled_lines

      split_output = compiled_lines.map { |line| line.output }

      page.content = split_output.join("\n")

      # Turn the nicks into characters
      nick_tags = stats[:nicks].map! { |n| Tag.new('char:' + n) }
      page.data['rp_tags'] = (nick_tags.merge page.data['rp_tags']).to_a.sort
      page.data['last_post_time'] = stats[:last_post_time].strftime("%Y-%m-%d")
      page.data['start_date'] ||= stats[:first_post_time]
    end

    def get_options(page)
      { :strict_ooc => page.data['strict_ooc'],
        :merge_text_into_rp => page.data['merge_text_into_rp'] }
    end

    def merge_lines!(compiled_lines)
      last_line = nil
      compiled_lines.reject! { |line| 
        if last_line == nil then
          last_line = line
          false
        elsif last_line.mergeable_with? line then
          last_line.merge! line
          # Delete the current line from output and maintain last_line 
          # in case we need to merge multiple times.
          true 
        else
          last_line = line
          false
        end
      }
    end

    def extract_stats(compiled_lines) 
      nicks = Set.new
      compiled_lines.each { |line| 
        nicks << line.sender if line.output_type == :rp
      }

      { :nicks => nicks,
        :last_post_time => compiled_lines[-1].timestamp,
        :first_post_time => compiled_lines[0].timestamp }
    end
  end

end
