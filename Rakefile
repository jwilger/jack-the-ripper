require 'rubygems'
gem 'hoe', '=1.5.1'

require 'hoe'
require './lib/jack_the_ripper.rb'

Hoe.new('JackTheRIPper', JackTheRIPper::VERSION) do |p|
  p.rubyforge_name = 'jack_the_ripper'
  p.author = 'John Wilger'
  p.email = 'johnwilger@gmail.com'
  p.summary = 'RIP Postscript documents and transform images based on ' +
    'instructions pulled from Amazon SQS'
  p.description = p.paragraphs_of('README.txt', 2..5).join("\n\n")
  p.url = 'http://johnwilger.com/search?q=JackTheRIPper'
  p.changes = p.paragraphs_of('History.txt', 0..1).join("\n\n")
  p.extra_deps = %w( mime-types daemons right_aws )
end