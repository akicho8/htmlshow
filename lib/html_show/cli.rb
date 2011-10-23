#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require "html_show/generator"
require "optparse"

module HtmlShow
  class CLI
    def self.execute(args)
      config = {}

      oparser = OptionParser.new do |oparser|
        oparser.version = "0.0.1"
        oparser.banner = [
          "usage: #{oparser.program_name} [options] files...",
        ].collect{|e|e + "\n"}
        oparser.separator("options:")
        oparser.on("-i", "--files=FILES", "対象ファイル"){|config[:files]|}
        oparser.on("-r", "--range=RANGE", "範囲"){|config[:range]|}
        oparser.on("-a", "--assetsdir=DIR", "assetsディレクトリ", String){|config[:assetsdir]|}
        oparser.on("-o", "--outputdir=DIR", "出力ディレクトリ", String){|config[:outputdir]|}
        oparser.on("--title=TITLE", "タイトル", String){|config[:title]|}
        oparser.on("--reset", "全部消して作り直す？", TrueClass){|config[:reset]|}
        oparser.on("--[no-]static", "assetsをコピーする？", TrueClass){|config[:static]|}
      end

      args = oparser.parse(args)

      config[:files] = Array.wrap(config[:files]) + args

      if config[:files].empty?
        config[:files] << "*.html"
      end

      if config[:files].empty? && false
        puts oparser
        abort
      end

      HtmlShow.generate(config)
    end
  end
end

if $0 == __FILE__
  HtmlShow::CLI.execute([
      "--files=../../examples/*.html",
      "--assetsdir=../../examples/assets",
      "--outputdir=/tmp/_output2",
      "--range=0..100",
    ])

  HtmlShow::CLI.execute([])
end
