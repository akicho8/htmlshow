# -*- coding: utf-8 -*-

require "htmlshow/generator"
require "optparse"

module HtmlShow
  class CLI
    def self.execute(args)
      instance = HtmlShow::Generator.new
      config = instance.config

      oparser = OptionParser.new do |oparser|
        oparser.version = "0.0.4"
        oparser.banner = [
          "usage: #{oparser.program_name} [options] files...",
        ].collect{|e|e + "\n"}
        oparser.separator("options:")
        oparser.on("-i", "--files=FILES", "対象ファイル(オプションで指定してもいい)"){|config[:files]|}
        oparser.on("-r", "--range=RANGE", "範囲(初期値:指定なし)"){|config[:range]|}
        oparser.on("-a", "--assetsdir=DIR", "assetsディレクトリ(初期値:#{config[:assetsdir]})", String){|config[:assetsdir]|}
        oparser.on("--outputdir=DIR", "出力ディレクトリ(初期値:#{config[:outputdir]})", String){|config[:outputdir]|}
        oparser.on("-o", "--open", "index.html を自動的に開く(初期値:#{config[:open]})", TrueClass){|config[:open]|}
        oparser.on("--title=TITLE", "タイトル(初期値:pwdのtitleizeで#{config[:title]})", String){|config[:title]|}
        oparser.on("--reset", "全部消して作り直す？(初期値:#{config[:reset]})", TrueClass){|config[:reset]|}
        oparser.on("--[no-]static", "assetsをコピーする？(初期値:#{config[:static]})", TrueClass){|config[:static]|}
        oparser.on("--[no-]relpath", "assetsをsymlinkするとき相対パスにしとく？(初期値:#{config[:relpath]})", TrueClass){|config[:relpath]|}
        oparser.on("--[no-]keyboard", "ページングをキーボードで操作する？(初期値:#{config[:keyboard]})", TrueClass){|config[:keyboard]|}
        oparser.on("--[no-]prettify", "コードに色付けする？(初期値:#{config[:prettify]})", TrueClass){|config[:prettify]|}
      end

      args = oparser.parse(args)

      config[:files] = Array.wrap(config[:files]) + args

      if config[:files].empty?
        config[:files] << "*.html"
      end

      HtmlShow.generate(config)
    end
  end
end

if $0 == __FILE__
  # HtmlShow::CLI.execute([
  #     "--files=../../examples/*.html",
  #     "--assetsdir=../../examples/assets",
  #     "--outputdir=/tmp/_output2",
  #     "--range=0..100",
  #   ])

  # HtmlShow::CLI.execute([])

  HtmlShow::CLI.execute(ARGV)
end
