Gem::Specification.new do |spec|
  spec.name = "htmlshow"
  spec.version = "0.0.4"
  spec.summary = "HTML convert to decorated HTML"
  spec.author = "akicho8"
  spec.homepage = "http://github.com/akicho8/html_show"
  spec.description = "HTML5, JavaScript, CSS3 etc... minimum test files convert t presentation files"
  spec.email = "akicho8@gmail.com"
  spec.files = %x[git ls-files].scan(/\S+/)
  spec.test_files = []
  spec.rdoc_options = ["--line-numbers", "--inline-source", "--charset=UTF-8", "--diagram", "--image-format=jpg"]
  spec.executables = ["htmlshow"]
  spec.platform = Gem::Platform::RUBY
  spec.add_dependency("activesupport")
end
