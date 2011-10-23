#!/usr/bin/env ruby
require "html_show"
HtmlShow.generate(:static => true)
`open _present_html/index.html`
