module SkillsHelper

  def filter_translation(filter)
    puts "---- Filter expression ----"
    if filter
      #filter = filter.downcase # switch to downcase if not empty
      values_filter = case
        when filter.index('like')
          "code.c=[#{filter.strip[filter.strip.index('like')+5..-1].strip}]".gsub(/'/,'')
        when filter.index('between')
          "code.in=[#{filter.strip.split[2]},#{filter.strip.split[4]}]".gsub(/'/,'')
        when filter.index('not in')
          "code.nc=[#{filter.strip[filter.strip.index('(')..-1].gsub(/[(')]/,'')}]"
        when filter.index('in')
          "code.c=[#{filter.strip[filter.index('(')..-1].gsub(/[(')]/,'')}]"
        when filter.index('>=')
          "code.gte=#{filter.strip[filter.strip.index('>=')+2..-1].strip}".gsub(/'/,'')
        when filter.index('<=')
          "code.lte=#{filter.strip[filter.strip.index('<=')+2..-1].strip}".gsub(/'/,'')
        when filter.index('<>')
          "code.ne=#{filter.strip[filter.strip.index('<>')+2..-1].strip}".gsub(/'/,'')
        when filter.index('<')
          "code.lt=#{filter.strip[filter.strip.index('<')+1..-1].strip}".gsub(/'/,'')
        when filter.index('>')
          "code.gt=#{filter.strip[filter.strip.index('>')+1..-1].strip}".gsub(/'/,'')
        when filter.index('=')
          "code.eq=#{filter.strip[filter.strip.index('=')+1..-1].strip}".gsub(/'/,'')
        else nil
      end
    else
      values_filter = ""
    end
    return values_filter
  end

end
