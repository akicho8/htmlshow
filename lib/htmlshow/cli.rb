# -*- coding: utf-8 -*-

require "htmlshow/generator"
require "optparse"

module Htmlshow
  class CLI
    def self.execute(args)
      instance = Htmlshow::Generator.new
      config = instance.config

      oparser = OptionParser.new do |oparser|
        oparser.version = "0.0.5"
        oparser.banner = [
          "usage: #{oparser.program_name} [options] files...",
        ].collect{|e|e + "\n"}
        oparser.separator("options:")
        oparser.on("-i", "--files=FILES", "対象ファイル(オプションで指定してもいい)"){|v|config[:files] = v}
        oparser.on("-r", "--range=RANGE", "範囲(初期値:指定なし)"){|v|config[:range] = v}
        oparser.on("-a", "--assetsdir=DIR", "assetsディレクトリ(初期値:#{config[:assetsdir]})", String){|v|config[:assetsdir] = v}
        oparser.on("--outputdir=DIR", "出力ディレクトリ(初期値:#{config[:outputdir]})", String){|v|config[:outputdir] = v}
        oparser.on("-o", "--open", "index.html を自動的に開く(初期値:#{config[:open]})", TrueClass){|v|config[:open] = v}
        oparser.on("--title=TITLE", "タイトル(初期値:pwdのtitleizeで#{config[:title]})", String){|v|config[:title] = v}
        oparser.on("--reset", "全部消して作り直す？(初期値:#{config[:reset]})", TrueClass){|v|config[:reset] = v}
        oparser.on("--[no-]static", "assetsをコピーする？(初期値:#{config[:static]})", TrueClass){|v|config[:static] = v}
        oparser.on("--[no-]relpath", "assetsをsymlinkするとき相対パスにしとく？(初期値:#{config[:relpath]})", TrueClass){|v|config[:relpath] = v}
        oparser.on("--[no-]keyboard", "ページングをキーボードで操作する？(初期値:#{config[:keyboard]})", TrueClass){|v|config[:keyboard] = v}
        oparser.on("--[no-]prettify", "コードに色付けする？(初期値:#{config[:prettify]})", TrueClass){|v|config[:prettify] = v}
      end

      args = oparser.parse(args)

      config[:files] = Array.wrap(config[:files]) + args

      if config[:files].empty?
        config[:files] << "*.html"
      end

      Htmlshow.generate(config)
    end
  end
end

if $0 == __FILE__
  # Htmlshow::CLI.execute([
  #     "--files=../../examples/*.html",
  #     "--assetsdir=../../examples/assets",
  #     "--outputdir=/tmp/_output2",
  #     "--range=0..100",
  #   ])

  # Htmlshow::CLI.execute([])

  Htmlshow::CLI.execute(ARGV)
end
