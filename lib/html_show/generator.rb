# -*- coding: utf-8 -*-

require "active_support/core_ext/string"
require "active_support/core_ext/array"
require "pathname"
require "fileutils"
require "cgi"
require "pp"

module HtmlShow
  def self.generate(*args, &block)
    Generator.new(*args, &block).run
  end

  class Generator
    attr_accessor :config

    def initialize(config = {}, &block)
      @config = {
        :reset          => false,
        :static         => false,
        :files          => [],
        :outputdir      => "_show_files",
        :assetsdir      => "assets",
        :title          => Pathname.pwd.basename.to_s.titleize,
        :verbose        => false,
        :css            => "htmlshow.css",
        :index_template => "index.html.erb",
        :prettify       => true,
        :open           => false,
        :relpath        => true,
        :keyboard       => true,
      }.merge(config)

      if block_given?
        yield @config
      end
    end

    def run
      if @config[:reset]
        FileUtils.rm_rf(outputdir, :verbose => @config[:verbose])
      end
      FileUtils.makedirs(outputdir, :verbose => @config[:verbose])
      make_assets_symlink
      target_files.each_with_index{|current_file, @current_index|
        @content = current_file.read
        output_file = outputdir + current_file.basename
        @number = current_file.basename.to_s.to_i
        output_file.open("w"){|f|f << new_content}
        puts "write: #{output_file} (#{@current_index.next}/#{target_files.size})"
      }
      make_index_html
      puts "#{target_files.size} files done."
      if @config[:open]
        if RUBY_PLATFORM.match(/darwin/)
          `open #{index_html}`
        else
          `start #{index_html}`
        end
      end
    end

    private

    def target_files
      return @target_files if @target_files

      @target_files = Array.wrap(@config[:files]).collect{|file|Pathname.glob(file)}
      @target_files = @target_files.flatten.find_all{|file|file.basename.to_s.match(/^\d+/)}.sort

      if range_value
        @target_files = @target_files.find_all{|file|range_value.include?(file.basename.to_s.to_i)}
      end

      @target_files
    end

    def make_assets_symlink
      unless source_assets_path.exist?
        puts "Source assets directory not found: #{source_assets_path}"
        return
      end

      dest_assets_path = outputdir + source_assets_path.basename
      if dest_assets_path.exist?
        puts "Destination assets directory already exist: #{source_assets_path}"
        return
      end

      if @config[:static]
        FileUtils.cp_r(source_assets_path, outputdir, :verbose => @config[:verbose])
      else
        if @config[:relpath]
          path = source_assets_path.relative_path_from(outputdir)
        else
          path = source_assets_path
        end
        puts "ln -s #{dest_assets_path} #{path}"
        dest_assets_path.make_symlink(path)
      end
    end

    def each_file
      target_files.each_with_index do |file, index|
        @content = file.read
        yield file, index
      end
    end

    def h1_part
      if memo_parts
        memo_parts.first
      end
    end

    def memo_parts
      if md = @content.match(/\A(.*)<!doctype html>/im)
        md.captures.first.scan(/<!-- (.*) -->/).flatten
      end
    end

    def short_memo_part
      if memo_parts
        memo_parts[1..-1]
      end
    end

    def js_part
      if md = @content.match(/<script type=\"text\/javascript\">\n(.*)\n\s*<\/script>/m)
        md.captures.first.lines.to_a[1..-2].join.strip_heredoc
      end
    end

    def js_include_files
      @content.scan(/<script.*src="(\S+\.js)"/).flatten
    end

    def part_for(name)
      if md = @content.match(/<#{name}>(.*)<\/#{name}>/m)
        str = md.captures.first
        str = str.gsub(/<!-- .*? -->/, "")
        str.strip_heredoc.strip
      end
    end

    def paginate
      html = ""
      html << "<div class=\"__hs_paginate\">\n"
      html << "<a href=\"index.html\" class=\"index\">■</a>\n"
      html << "#{@current_index.next} / #{target_files.size}\n"
      if file = next_file(-1)
        str = CGI.escapeHTML("戻る")
        html << "    <a href=\"#{file}\" class=\"prev\">#{str}</a>\n"
      end
      if file = next_file(+1)
        str = CGI.escapeHTML("もっと見る")
        html << "    <a href=\"#{file}\" class=\"next\">#{str}</a>\n"
      end
      html << "</div>\n"
    end

    def stylesheet_link_tag
      if css_file && css_file.exist?
        "<link href=\"#{css_file.basename}\" media=\"screen\" rel=\"Stylesheet\" type=\"text/css\" />"
      end
    end

    def new_content
      new_content = @content.dup

      new_content = new_content.gsub(/(<head>)/){
        html = ""
        html << "#{$1}\n"
        html << stylesheet_link_tag
      }

      if require_jqeury?
        unless js_include_files.join(",").match(/\b(jquery)\b/)
          new_content = new_content.gsub(/(<head>)/){
            html = ""
            html << "#{$1}\n"
            html << "<script src=\"jquery.js\" type=\"text/javascript\"></script>\n"
          }
        end
      end

      if @config[:prettify]
        new_content = new_content.gsub(/(<\/head>)/){
          html = ""
          html << "<script src=\"prettify.js\" type=\"text/javascript\"></script>\n"
          html << "<link href=\"prettify.css\" media=\"screen\" rel=\"stylesheet\" type=\"text/css\" />\n"
          html << "<script>$(function(){if(!$.__pp__){prettyPrint();$.__pp__=1}})</script>\n"
          html << "#{$1}\n"
        }
      end

      new_content = new_content.gsub(/(<\/head>)/){
        html = ""
        html << "<script src=\"htmlshow.js\" type=\"text/javascript\"></script>\n"
        html << "#{$1}\n"
      }

      new_content = new_content.gsub(/<body>(.*)<\/body>/m){
        html = ""
        html << "<body>\n"
        html << "<div class=\"__hs_container __hs_clearfix\">\n"
        html << "#{$1}"
        html << "</div>\n"
        html << "</body>\n"
      }

      new_content = new_content.gsub(/(<body>\n)/){
        html = ""
        html << "#{$1}"
        html << paginate
        html << "    <h1 class=\"__hs__\">#{@current_index.next}. #{h1_part}</h1>\n"
      }

      new_content = new_content.gsub(/(<\/body>)/){
        html = ""
        if part_for(:body).present?
          html << "<section class=\"__hs__\">\n"
          html << "  <h2 class=\"__hs__\">HTML</h2>\n"
          html << "  <pre class=\"prettyprint linenums\">#{CGI.escapeHTML(part_for(:body))}</pre>\n"
          html << "</section>\n"
        end
        if js_part.present?
          html << "<section class=\"__hs__\">\n"
          html << "  <h2 class=\"__hs__\">JavaScript</h2>\n"
          html << "  <pre class=\"prettyprint linenums\">#{CGI.escapeHTML(js_part)}</pre>\n"
          html << "</section>\n"
        end
        if short_memo_part.present?
          html << "<section class=\"__hs__\">\n"
          html << "  <h2 class=\"__hs__\">MEMO</h2>\n"
          str = short_memo_part.join("\n")
          html << "  <pre class=\"__hs__\">#{CGI.escapeHTML(str)}</pre>\n"
          html << "</section>\n"
        end
        html << paginate
        html << "#{$1}"
      }

      new_content
    end

    def require_jqeury?
      true
    end

    def next_file(add)
      index = @current_index + add
      if true
        if target_files.size.nonzero?
          target_files[index.modulo(target_files.size)].basename
        end
      else
        if (0...target_files.size).include?(index)
          target_files[index].basename
        end
      end
    end

    def make_index_html
      FileUtils.cp(Pathname(__FILE__).dirname.join("jquery.js"), outputdir, :verbose => true)
      FileUtils.cp(Pathname(__FILE__).dirname.join("htmlshow.js"), outputdir, :verbose => true)

      if @config[:prettify]
        FileUtils.cp(Pathname(__FILE__).dirname.join("prettify.js"), outputdir, :verbose => true)
        FileUtils.cp(Pathname(__FILE__).dirname.join("prettify.css"), outputdir, :verbose => true)
      end

      if css_file.exist?
        FileUtils.cp(css_file, outputdir, :verbose => true)
      end

      index_html.open("w"){|f|f << ERB.new(index_template.read).result(binding)}
      puts "write: #{index_html}"
    end

    def index_html
      outputdir + index_template.basename.to_s.gsub(/\.erb\z/, "")
    end

    def outputdir
      Pathname(@config[:outputdir]).expand_path
    end

    def source_assets_path
      Pathname(@config[:assetsdir]).expand_path
    end

    def index_template
      file = Pathname(@config[:index_template])
      if file.exist?
        return file
      end

      Pathname(__FILE__).dirname.join("index.html.erb").expand_path
    end

    def css_file
      if @config[:css].empty?
        return
      end

      css = Pathname(@config[:css])
      if css.exist?
        return css
      end

      Pathname(__FILE__).dirname.join("htmlshow.css")
    end

    def range_value
      case @config[:range]
      when /\A\d+\.+\d+\z/, /\A\d+\z/
        eval(@config[:range])
      else
        @config[:range]
      end
    end
  end
end

if $0 == __FILE__
  HtmlShow.generate do |config|
    config[:files] = Pathname(__FILE__).dirname.join("../../examples/*.html").expand_path
    config[:range] = 0..100
    config[:static] = false
    config[:reset] = true
    config[:assetsdir] = Pathname(__FILE__).dirname.join("../../examples/assets").expand_path
    # config[:outputdir] = "/tmp/_output"
    config[:prettify] = true
    # config[:relpath] = false
    config[:open] = true
  end
end
