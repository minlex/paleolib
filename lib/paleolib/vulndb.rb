require 'rubygems'
require 'nokogiri'
require 'sqlite3'


class CVEmitre

  def initialize(file)
    @db = SQLite3::Database.new(file)
    @threshold = 0.9
  end

  def self.count_matches(vuln,words,len)
    count = 0    
    words.each { |word|

      if vuln[1].match /#{word}/i
          count +=1
      end
    }
    res = (count/len.to_f)
    $log.debug "Matches: #{res}"
    
    return res
  end

  def exclude_common_words(words)
    
    words.select! { |word| not word.match /commons|common|db|crypt|org|com|net|custom|toolkit|file|jar|^\d.*$/i }
   $log.debug words.inspect
    
  end
  
  def fuzzy_search(word)
    # Not realy fuzzy search
    search_result = []
    
    if  search_result == []
      res = word.split(/\-| |\./).map{ |i| i.chomp }
      len = res.length
      exclude_common_words(res)
      if  res.length > 1
        full_search = []
        res.each  { |item| full_search  << self.search(item) }
        full_search.flatten! 1
        
        full_search.select! { |vuln| CVEmitre.count_matches(vuln,res,len) >= @threshold unless vuln[2].nil?}        
        return full_search
      end
    end
    return search_result
  end
    
  def search(word)
      if word =~ /commons|oracle|custom|toolkit|vmware/i
        return []
      end
    rows = @db.execute("select * from cves where desc like \"\%#{word}\%\";")
    return rows
  end
end
