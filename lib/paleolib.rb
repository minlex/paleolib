
require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'sqlite3'
require 'zip/zip'
require 'logger'

require 'paleolib/parsers'
require 'paleolib/vulndb'
    

    
class LibWalk

  def initialize(dbfile,verbosity=false)
    @db = CVEmitre.new(dbfile)
    @count_libs = 0
    @count_vulns = 0
    @verbosity = verbosity
  end
  

  def print_cve(results)
    results.each do |vuln|
      puts("[[%s]]" % vuln[0])
      puts("%-8s: %s" % ["Description",vuln[1]])
      refs = vuln[2].split('|')
      refs.each do |ref|
        ref = ref.split(',')
        puts("%-8s: %s" % [ref[0],ref[1]])
      end
      puts("\n")
    end    
  end
  
  def walk(path)
    if File.directory?(path)
      files = Dir["#{path}/*"]
      if @verbosity 
        puts("Directory: #{path}")
      end
        files.each{ |x| walk(x)}
    else
      ext = File.extname(path)
      case ext
      when ".jar"
        info = Parsers::Jar.new(path)
      when (".exe" or ".ddl")
        info = Parsers::PE.new(path)

      end

      
      if not info.nil?
        if not info.product.nil?
          result = @db.fuzzy_search(info.product)
        else 
          result = @db.fuzzy_search(info.filename)
      end      
      if @verbosity == true or result != []
        info.print
      end
      print_cve(result) unless result == []  or result.nil?


      @count_libs +=1
      @count_vulns +=result.length unless (result == [] or result.nil?)
      end      
    end

    def print_summary
      puts "Summary"
      puts "Found library: #{@count_libs}"
      puts "Found vulnereabilites: #{@count_vulns}"      
    end    
  end
end

$log = Logger.new(STDOUT)
$log.level = Logger::INFO

