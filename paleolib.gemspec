Gem::Specification.new do |s|
  s.name        = 'paleolib'
  s.version     = '0.1.1'
  s.executables << "paleolib"
  s.date        = '2012-07-06'
  s.summary     = "paleolib"
  s.description = "description"
  s.authors     = ["Alexander Minozhenko"]
  s.email       = 'minozhenko@gmail.com'
  s.files       = ["lib/paleolib.rb","lib/paleolib/parsers.rb","lib/paleolib/vulndb.rb"]
  s.add_runtime_dependency 'rubyzip',['>= 0' ]
  s.add_runtime_dependency 'sqlite3',['>= 0' ]
  s.add_runtime_dependency 'nokogiri',['>= 0' ]
end
