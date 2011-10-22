Gem::Specification.new do |spec|
  spec.name = "present_html_generator"
  spec.version = "0.0.1"
  spec.summary = "present_html_generator"
  spec.author = "akicho8"
  spec.homepage = "http://github.com/akicho8/present_html_generator"
  spec.description = "present_html_generator description"
  spec.email = "akicho8@gmail.com"
  spec.files = %x[git ls-files].scan(/\S+/)
  spec.test_files = []
  spec.rdoc_options = ["--line-numbers", "--inline-source", "--charset=UTF-8", "--diagram", "--image-format=jpg"]
  spec.executables = ["present_html_generator"]
  spec.platform = Gem::Platform::RUBY
  spec.add_dependency("activesupport")
end
