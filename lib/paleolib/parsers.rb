

require 'rubygems'
require 'pedump'
require 'zip/zip'

module Parsers
  
  class Jar
    attr_accessor :filename, :version, :vendor, :product    
    def initialize(file)
      @filename = File.basename file
      parse_manifest(file)      
    end

    def is_match? file
      fname = File.basename file
      if File.extname(fname) == ".jar"
        parse_manifest(fname)
      end
    end
      
    def to_s
      return @filename
    end

    def parse_manifest(file)
      begin
        Zip::ZipFile.open(file) { |jarfile|        
          content = jarfile.read("META-INF/MANIFEST.MF")
          @version = content.scan(/^(Specification|Implementation)-Version: (.*)$/).flatten.pop  
          @vendor = content.scan(/^(Specification|Implementation)-Vendor: (.*)$/).flatten.pop
          @product = content.scan(/^(Specification|Implementation)-Title: (.*)$/).flatten.pop

        }
      rescue Errno::ENOENT
        return
      end
    end

    def print
      [:filename, :version, :vendor, :product].each { |val|    
        puts "%-8s: %s" %  [val.to_s.capitalize,self.send(val)] unless self.send(val).nil?
      }
      puts("\n")
    end
  end

  class PE
    attr_accessor :filename, :version, :vendor, :product
    
    def initialize(file)
      dump_info(file)
    end

    def to_s
      return @product
    end
    
    def dump_info(file)
      f=File.open(file, 'rb') do |f|
        pedump=PEdump.new(f, :force => true)
        data = pedump.version_info
        data.each do |vi|
          vi.Children.each do |file_info|
            case file_info
            when PEdump::StringFileInfo, PEdump::NE::StringFileInfo
              file_info.Children.each do |string_table|
                string_table.Children.each do |string|
                  case string.szKey
                  when "CompanyName"
                    @vendor = string.Value
                  when "ProductName"
                    @product = string.Value
                  when "ProductVersion"
                    @version = string.Value
                  end                          
                end
              end
            end
          end
        end        
      end
      return @vendor, @product, @version
    end
  end

  class General
    attr_accessor :filename, :version, :vendor, :product
    def initialize(file)

      @filename = File.basename(file,File.extname(file))
      res = @filename.match(/([\d\.]+)/)
      if not res.nil?
        @version = res.to_s
        @filename = @filename[0..res.begin(0)-1]
      end
    end

    def to_s
      return @filename
    end
    
    def print
      [:filename, :version].each { |val|    
        puts("%-8s: %s" %  [val.to_s.capitalize,self.send(val)]) unless self.send(val).nil?
      }
      puts("\n")
    end
  end   
end
