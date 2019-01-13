
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "pytty/version"

Gem::Specification.new do |spec|
  spec.name          = "pytty"
  spec.version       = Pytty::VERSION
  spec.authors       = ["Matti Paksula"]
  spec.email         = ["matti.paksula@iki.fi"]

  spec.summary       = "pytty"
  spec.homepage      = "https://github.com/pyttyhq/pytty-ruby"
  spec.license       = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  ignored_files = ["Dockerfile", "docker-compose.yml",
    ".dockerignore",".gitignore",
    ".ruby-gemset",".ruby-version",
    ".rspec",
    ".travis.yml",
    "Guardfile"
  ]
  spec.files = spec.files - ignored_files

  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "clamp", "~> 1.3"
  spec.add_runtime_dependency "falcon"
  spec.add_runtime_dependency "async-websocket"
  spec.add_runtime_dependency "mustermann"

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "guard"
  spec.add_development_dependency "guard-rspec"
  spec.add_development_dependency "guard-bundler"
  spec.add_development_dependency "guard-process"
end
