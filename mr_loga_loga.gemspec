# frozen_string_literal: true

require_relative 'lib/mr_loga_loga/version'

Gem::Specification.new do |spec|
  spec.name = 'mr_loga_loga'
  spec.version = MrLogaLoga::VERSION
  spec.authors = ['hschne']
  spec.email = ['hans.schnedlitz@gmail.com']

  spec.summary = 'A bombastic, fantastic logger for Ruby'
  spec.description = 'A bombastic, fantastic logger for Ruby'
  spec.homepage = 'https://github.com/hschne/mr-loga-loga'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 2.6.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata['rubygems_mfa_required'] = 'true'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
  spec.add_development_dependency 'byebug'
  spec.add_development_dependency 'rubocop', '~> 1.24'
  spec.add_development_dependency 'simplecov', '~> 0.21.2'
  spec.add_development_dependency 'timecop', '~> 0.9.4'
end
