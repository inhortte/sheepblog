Gem::Specification.new do |s|
  s.name                      = "user"
  s.version                   = "0.1.0"
  s.required_rubygems_version = ">= 1.3.7"
  s.authors                   = ["Bob Shelton"]
  s.date                      = "2010-12-14"
  s.email                     = ["inhortte@gmail.com"]
  s.files                     = Dir['lib/user.rb']
  s.summary                   = "The user model for a simple blog"

  s.add_runtime_dependency "dm-core"
end
