#!/usr/bin/env ruby
require "htmlshow"
Htmlshow.generate(:static => true)
`open _present_html/index.html`
