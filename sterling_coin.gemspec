Gem::Specification.new do |s|
  s.name        = 'sterling_coin'
  s.version     = '0.13.0'
  s.date        = '2015-08-20'
  s.summary     = "personal finance manager"
  s.description = "personal finance manager"
  s.authors     = ["Serpent7776"]
  s.email       = 'serpent7776@gmail.com'
  s.files       = `git ls-files lib/`.split "\n"
  s.executables = `git ls-files bin/`.split("\n").map{|file| file.gsub('bin/', '')}
  s.homepage    = 'https://github.com/serpent7776/sterling'
  s.license     = 'BSD'
  s.add_runtime_dependency 'gtk2', ['~> 2.2']
  s.add_runtime_dependency 'xdg', ['~> 2.2']
  s.add_runtime_dependency 'rdbi', ['~> 1.1']
  s.add_runtime_dependency 'rdbi-driver-sqlite3', ['~> 0.9']
end
