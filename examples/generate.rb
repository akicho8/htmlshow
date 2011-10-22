#!/usr/bin/env ruby
require "present_html_generator"
PresentHtmlGenerator.generate(:static => true)
`open _present_html/index.html`
