# GitHub Markdown to HTML Converter
This is a conversion script that converts Markdown to HTML, using GitHub's own CSS to render it, allowing for conversion of Markdown files to a GitHub flavored Markdown `.html` file.

In order to use this Ruby script, you first need to install the gem: `redcarpet` 

```bash
# Assuming you have Ruby installed
gem install redcarpet

# Then use it like this
ruby md2html.rb README.md README.html
```
