lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "mysqlman/version"

Gem::Specification.new do |spec|
  spec.name          = "mysqlman"
  spec.version       = Mysqlman::VERSION
  spec.authors       = ["onunu"]
  spec.email         = ["riku.onuma@livesense.co.jp", "onunu@zeals.co.jp"]

  spec.summary       = %q{Management your mysql users.}
  spec.description   = %q{Management your mysql users. You can do that by simple settings written by yaml}
  spec.homepage      = "https://github.com/onunu/mysqlman"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "mysql2"
  spec.add_dependency "thor"

  spec.add_development_dependency "bundler", "~> 1.16.a"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
