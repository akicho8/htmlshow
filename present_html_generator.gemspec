Gem::Specification.new do |spec|
  spec.name = "present_html_generator"
  spec.version = "0.0.1"
  spec.summary = "present_html_generator"
  spec.author = "akicho8"
  spec.homepage = "http://github.com/akicho8"
  spec.description = "present_html_generator"
  spec.email = "akicho8@gmail.com"
  spec.files = Dir.glob("**/*").reject{|e|e.match("/_present_html/")}
  spec.test_files = Dir.glob("test/test_*.rb")
  spec.rdoc_options = ["--line-numbers", "--inline-source", "--charset=UTF-8", "--diagram", "--image-format=jpg"]
  spec.executables = ["present_html_generator"]
  spec.platform = Gem::Platform::RUBY
  spec.add_dependency("activesupport")
end
