Gem::Specification.new do |spec|
  spec.name          = "marktable"
  spec.version       = "0.1.0"
  spec.authors       = ["Your Name"]
  spec.email         = ["your.email@example.com"]

  spec.summary       = "A brief summary of the Marktable gem."
  spec.description   = "A longer description of the Marktable gem."
  spec.homepage      = "https://github.com/yourusername/marktable"
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*.rb"] + ["README.md", "LICENSE"]
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rake", "~> 13.0"
end
