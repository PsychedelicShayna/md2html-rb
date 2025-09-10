#!/usr/bin/ruby
require 'redcarpet'
require 'erb'

input = ARGV[0] && ARGV[0] != "-" &&  File.open(ARGV[0]) || STDIN
output = ARGV[1] && File.open(ARGV[1], "w") || STDOUT

File.join(ENV["XDG_CACHE_HOME"] || "#{ENV['HOME']}/.cache", "gfm-render")

class RenderWithTaskLists < Redcarpet::Render::HTML
  def list_item(text, list_type)
    if text.start_with?("[x]", "[X]")
      text[0..2] = %(<input type="checkbox" class="task-list-item-checkbox" disabled="" checked="checked">)
    elsif text.start_with?("[ ]")
      text[0..2] = %(<input type="checkbox" class="task-list-item-checkbox" disabled="">)
    end

    %(<li class="task-list-item">#{text}</li>)
  end
end

markdown_renderer = Redcarpet::Markdown.new(
  RenderWithTaskLists,
  no_intra_emphasis: true,
  autolink: true,
  tables: true,
  fenced_code_blocks: true,
  lax_spacing: true,
)

html_output = markdown_renderer.render(input.read)
name = input.is_a?(File) && File.basename(input) || "<stdin>"
gh_markdown_css_filename = File.join(ENV["XDG_CACHE_HOME"] || "#{ENV['HOME']}/.cache", "gfm-render/github-markdown.css")

unless File.exist?(gh_markdown_css_filename)
  require 'net/http'
  require 'pathname'
  CSS_URL = 'https://raw.githubusercontent.com/sindresorhus/github-markdown-css/main/github-markdown.css'
  STDERR.puts "Download #{CSS_URL} and cache to #{gh_markdown_css_filename}"
  Pathname.new(gh_markdown_css_filename).dirname.mkpath
  File.open(gh_markdown_css_filename, "w") do |css|
    css.write(Net::HTTP.get(URI(CSS_URL)))
  end
end
gh_markdown_css = File.read(gh_markdown_css_filename)

erb = ERB.new(DATA.read)
output.write(erb.result)

__END__
<html>
  <head>
    <meta charset="utf-8">
    <title>Rendered <%= name %></title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
                                                                                                  
    <style>

      <%= gh_markdown_css %>

      @media (prefers-color-scheme: dark) {
          body {
              color: #c9d1d9;
              background-color: #0d1117;
          }
      }
      @media (prefers-color-scheme: light) {
          body {
              color: #24292f;
              background-color: #ffffff;
          }
      }

      .markdown-body {
	  box-sizing: border-box;
	  min-width: 200px;
	  max-width: 980px;
	  margin: 1 auto;
	  padding: 45px;
          border: 1px solid #d0d7de;
          border-radius: 6px;
      }

      @media (max-width: 767px) {
	  .markdown-body {
	      padding: 15px;
	  }
      }
    </style>
  </head>
  <body>
    <article class="markdown-body">
<%= html_output %>    
    </article>
  </body>
</html>

