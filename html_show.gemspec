Gem::Specification.new do |spec|
  spec.name = "html_show"
  spec.version = "0.0.1"
  spec.summary = "html_show"
  spec.author = "akicho8"
  spec.homepage = "http://github.com/akicho8/html_show"
  spec.description = "html_show description"
  spec.email = "akicho8@gmail.com"
  spec.files = %x[git ls-files].scan(/\S+/)
  spec.test_files = []
  spec.rdoc_options = ["--line-numbers", "--inline-source", "--charset=UTF-8", "--diagram", "--image-format=jpg"]
  spec.executables = ["html_show"]
  spec.platform = Gem::Platform::RUBY
  spec.add_dependency("activesupport")
end
