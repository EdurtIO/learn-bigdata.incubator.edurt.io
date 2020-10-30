# coding: utf-8

Gem::Specification.new do |spec|
  spec.name          = "incubator-docs"
  spec.version       = "0.3.3"
  spec.authors       = ["qianmoQ"]
  spec.email         = ["shicheng@ttxit.com"]

  spec.summary       = %q{Jekyll文档模版}
  spec.homepage      = "https://github.com/EdurtIO/incubator-docs.git"

  spec.files         = `git ls-files -z`.split("\x0").select { |f| f.match(%r{^(assets|bin|_layouts|_includes|lib|Rakefile|_sass|LICENSE|README)}i) }
  spec.executables   << 'incubator-docs'

  spec.add_development_dependency "bundler", "~> 2.1.4"
  spec.add_runtime_dependency "jekyll", ">= 3.8.5"
  spec.add_runtime_dependency "jekyll-seo-tag", "~> 2.0"
  spec.add_runtime_dependency "rake", ">= 12.3.1", "< 13.1.0"

end