# frozen_string_literal: true

require_relative "lib/gyros/version"

Gem::Specification.new do |spec|
  spec.name = "gyros"
  spec.version = Gyros::VERSION
  spec.authors = ["Kirill Zaitsev"]
  spec.email = ["kirik910@gmail.com"]

  spec.summary = 'Library which helps build queries dynamically'
  spec.description = 'Library which helps build queries dynamically'
  spec.homepage = 'http://example.com'
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
