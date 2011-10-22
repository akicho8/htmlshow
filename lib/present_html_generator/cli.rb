#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require "present_html_generator/generator"
require "optparse"
require "pathname"

module PresentHtmlGenerator
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
        puts oparser
        abort
      end

      PresentHtmlGenerator.generate(config)
    end
  end
end

if $0 == __FILE__
  PresentHtmlGenerator::CLI.execute([
      "--files=../../examples/*.html",
      "--assetsdir=../../examples/assets",
      "--outputdir=/tmp/_output2",
      "--range=0..100",
    ])

  PresentHtmlGenerator::CLI.execute([])
end
