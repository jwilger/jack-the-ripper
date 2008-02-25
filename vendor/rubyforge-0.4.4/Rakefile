# -*- ruby -*-

begin
  require 'hoe'
rescue LoadError
  abort "ERROR: This Rakefile is only useful with hoe installed.
       If you're trying to install the rubyforge library,
       please install it via rubygems."
end

Object.send :remove_const, :RubyForge if defined? RubyForge
require './lib/rubyforge.rb'

Hoe.new("rubyforge", RubyForge::VERSION) do |p|
  p.rubyforge_name = "codeforpeople"
  p.url = "http://rubyforge.org/projects/codeforpeople"
  p.author = ['Ara T Howard', 'Ryan Davis', 'Eric Hodel']
  p.need_tar = false

  changes = p.paragraphs_of("History.txt", 1..2).join("\n\n")
  summary, *description = p.paragraphs_of("README.txt", 3, 3..4)

  p.changes = changes
  p.summary = summary
  p.description = description.join("\n\n")
end

# vim:syntax=ruby
