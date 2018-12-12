begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)

  desc "Run tests"
  task default: :spec
rescue LoadError
  puts "Please install rspec"
end
