#!/usr/local/bin/ruby -Ku
# -*- coding: utf-8 -*-

require "rubygems"
require "active_support/all"
require "pathname"
require "fileutils"
require "cgi"
require "pp"

module PresentHtmlGenerator
  def self.generate(*args, &block)
    Generator.new(*args, &block).run
  end

  class Generator
    attr_accessor :config

    def initialize(config = {}, &block)
      @config = {
        :rebuild        => false,
        :static         => false,
        :files           => "*.html",
        :outputdir      => "_present_html",
        :assetsdir      => "assets",
        :title          => Pathname.pwd.basename.to_s.titleize,
        :verbose        => true,
        :css            => "application.css",
        :index_template => "index.html.erb",
      }.merge(config)

      if block_given?
        yield @config
      end
    end

    def run
      if @config[:rebuild]
        FileUtils.rm_rf(outputdir, :verbose => @config[:verbose])
      end
      FileUtils.makedirs(outputdir, :verbose => @config[:verbose])
      make_assets_symlink
      target_files.each_with_index{|current_file, @current_index|
        @content = current_file.read
        output_file = outputdir + current_file.basename
        @number = current_file.basename.to_s.to_i
        FileUtils.makedirs(output_file.dirname, :verbose => @config[:verbose])
        output_file.open("w"){|f|f << new_content}
        puts "write: #{output_file} (#{@current_index.next}/#{target_files.size})"
      }
      make_index_html
      puts "#{target_files.size} + 1 files done."
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
      unless assetsdir.exist?
        puts "Source assets directory not found: #{assetsdir}"
        return
      end

      dest_assets_path = outputdir + assetsdir.basename
      if dest_assets_path.exist?
        puts "Destination assets directory already exist: #{assetsdir}"
        return
      end

      if @config[:static]
        FileUtils.cp_r(assetsdir, outputdir, :verbose => @config[:verbose])
      else
        dest_assets_path.make_symlink(assetsdir)
        puts "ln -s #{assetsdir} #{dest_assets_path}"
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

    def body_part
      if md = @content.match(/<body>(.*)<\/body>/m)
        str = md.captures.first
        str = str.gsub(/<!-- .*? -->/, "")
        str.strip_heredoc.strip
      end
    end

    def paginate
      html = ""
      html << "<div class=\"paginate\">\n"
      html << "<a href=\"index.html\">INDEX</a>\n"
      html << "#{@current_index.next} / #{target_files.size}\n"
      if file = next_file(-1)
        str = CGI.escapeHTML("<<")
        html << "    <a href=\"#{file}\" class=\"prev\">#{str}</a>\n"
      end
      if file = next_file(+1)
        str = CGI.escapeHTML(">>")
        html << "    <a href=\"#{file}\" class=\"next\">#{str}</a>\n"
      end
      html << "</div>\n"
      html
    end

    def new_content
      new_content = @content.dup

      new_content = new_content.gsub(/(<head>)/){
        html = ""
        html << "#{$1}\n"
        html << "    <link href=\"stylesheets/study.css\" media=\"screen\" rel=\"Stylesheet\" type=\"text/css\" />"
        html
      }

      new_content = new_content.gsub(/<body>(.*)<\/body>/m){
        html = ""
        html << "<body>\n"
        html << "<div class=\"container clearfix\">\n"
        html << "#{$1}"
        html << "</div>\n"
        html << "</body>\n"
        html
      }

      new_content = new_content.gsub(/(<body>\n)/){
        html = ""
        html << "#{$1}"
        html << paginate
        html << "    <h1>#{h1_part}</h1>\n"
        html
      }

      new_content = new_content.gsub(/(<\/body>)/){
        html = ""
        if body_part.present?
          html << "<section id=\"body_part\">\n"
          html << "  <h2>HTML</h2>\n"
          html << "  <pre>#{CGI.escapeHTML(body_part)}</pre>\n"
          html << "</section>\n"
        end
        if js_part.present?
          html << "<section id=\"js_part\">\n"
          html << "  <h2>JavaScript</h2>\n"
          html << "  <pre>#{CGI.escapeHTML(js_part)}</pre>\n"
          html << "</section>\n"
        end
        if short_memo_part.present?
          html << "<section id=\"short_memo_part\">\n"
          html << "  <h2>MEMO</h2>\n"
          str = short_memo_part.join("\n")
          html << "  <pre>#{CGI.escapeHTML(str)}</pre>\n"
          html << "</section>\n"
        end
        html << paginate
        html << "#{$1}"
        html
      }

      new_content
    end

    def next_file(add)
      index = @current_index + add
      if (0...target_files.size).include?(index)
        target_files[index].basename
      end
    end

    def make_index_html
      FileUtils.cp(Pathname(__FILE__).dirname.join("jquery.js"), outputdir, :verbose => true)
      if css_file.exist?
        FileUtils.cp(css_file, outputdir, :verbose => true)
      end

      index_html = outputdir + index_template.basename.to_s.gsub(/\.erb\z/, "")
      index_html.open("w"){|f|f << ERB.new(index_template.read).result(binding)}
      puts "write: #{index_html}"
    end

    def outputdir
      Pathname(@config[:outputdir]).expand_path
    end

    def assetsdir
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
      if @config[:css].blank?
        return
      end

      css = Pathname(@config[:css])
      if css.exist?
        return css
      end

      Pathname(__FILE__).dirname.join("application.css")
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
  PresentHtmlGenerator.generate do |config|
    config[:files] = Pathname(__FILE__).dirname.join("../../examples/*.html").expand_path
    config[:range] = 0..100
    config[:static] = false
    config[:rebuild] = true
    config[:assetsdir] = Pathname(__FILE__).dirname.join("../../examples/assets").expand_path
    config[:outputdir] = "/tmp/_output"
  end
end
