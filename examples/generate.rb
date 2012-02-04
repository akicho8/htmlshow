#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
# rubyのコードで書く例
require "htmlshow"
Htmlshow.generate(:static => true)
`open _show_files/index.html`
