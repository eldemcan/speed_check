# frozen_string_literal: true

require_relative "lib/speed_check/version"

Gem::Specification.new do |spec|
  spec.name = "speed_check"
  spec.version = SpeedCheck::VERSION
  spec.authors = ["Can Eldem"]
  spec.email = ["eldemcan@users.noreply.github.com"]

  spec.summary =
    "A Ruby gem for sliding window rate limiting using Redis as the database."
  spec.description =
    "SpeedCheck provides a simple way to limit the number of requests or actions performed by a user or IP address within a certain time period."
  spec.homepage = "https://github.com/eldemcan/speed_check"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.7.0"

  spec.metadata["homepage_uri"] = "https://github.com/eldemcan/speed_check"
  spec.metadata["source_code_uri"] = "https://github.com/eldemcan/speed_check"
  spec.metadata["changelog_uri"] = "https://github.com/eldemcan/speed_check"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files =
    Dir.chdir(File.expand_path(__dir__)) do
      `git ls-files -z`.split("\x0")
        .reject do |f|
          (f == __FILE__) ||
            f.match(
              %r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)},
            )
        end
    end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
