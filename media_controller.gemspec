Gem::Specification.new do |s|
  s.name        = 'media_controller'
  s.version     = '1.0.3'
  s.summary     = "Media Cotroller"
  s.description = "Allows controlling HTML5 video and audio players from Ruby"
  s.authors     = ["Aimee Rivers"]
  s.email       = 'airi@dr.dk'
  s.files       = [
                    "lib/media_controller.rb",
                    "lib/media_controller/media.rb",
                    "lib/media_controller/audio.rb",
                    "lib/media_controller/video.rb"
                  ]
  s.license     = 'MIT'
  s.add_runtime_dependency "capybara", [">= 3"]
  s.add_development_dependency "rspec"
end
