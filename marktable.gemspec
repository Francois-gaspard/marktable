Gem::Specification.new do |spec|
  spec.name = "marktable"
  spec.version = '0.0.1'
  spec.required_ruby_version = '>= 3.4'
  spec.authors = ['Francois Gaspard']
  spec.email = ['fr@ncois.email']
  spec.summary = "Read, write, parse, and filter Markdown tables easily."
  spec.description = "Provides a row-based object model and utility methods " \
    "for creating, parsing, transforming, and exporting " \
    "Markdown tables in Ruby."
  spec.homepage = 'https://github.com/Francois-gaspard/marktable'
  spec.license = 'MIT'

  spec.files = Dir["lib/**/*.rb"] + ["README.md", "LICENSE"]
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rake", "~> 13.0"
end
