Gem::Specification.new do |spec|
  spec.name = "htmlshow"
  spec.version = "0.0.5"
  spec.summary = "HTML files convert to paginated html files"
  spec.author = "akicho8"
  spec.homepage = "http://github.com/akicho8/htmlshow"
  spec.description = "HTML5, JavaScript, CSS3 etc... minimum test files convert to paginated html files"
  spec.email = "akicho8@gmail.com"
  spec.files = %x[git ls-files].scan(/\S+/)
  spec.test_files = []
  spec.rdoc_options = ["--line-numbers", "--inline-source", "--charset=UTF-8", "--diagram", "--image-format=jpg"]
  spec.executables = ["htmlshow"]
  spec.platform = Gem::Platform::RUBY
  spec.add_dependency("activesupport")
end
