# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'tilt/erubis'

before do
  @contents = File.readlines('data/toc.txt')
end

helpers do
  def in_paragraphs(string)
    text = string.split("\n\n")
    index = -1 # increments before inclusion, so will start at 0
    text.map do |line|
      index += 1
      "<p id=\"#{index}\">#{line}</p>"
    end.join
  end

  def highlight(content, spotlight)
    content.gsub(spotlight, "<strong>#{spotlight}</strong>")
  end
end

not_found do
  # 'A lonely tumbleweed floats by, for there is no life here.'
  redirect '/'
end

get '/' do
  @title = 'The Adventures of Sherlock Holmes'
  erb(:home, layout: :layout)
end

get '/chapters/:number' do |num|
  @chapter_num  = num.to_i
  @chapter_name = "Chapter #{@chapter_num} - #{@contents[num.to_i - 1]}"
  redirect '/' unless (1..@contents.size).cover?(num.to_i)
  @chapter = File.read("data/chp#{num}.txt")
  erb(:chapter)
end

get '/search' do
  @query = params['query']
  @chapters = Hash.new('')
  (1..12).each { |chap_num| @chapters[chap_num] = File.read("data/chp#{chap_num}.txt") }
  @chapter_hits = @chapters.keys.filter { |num| @chapters[num].include?(@query) } if @query
  erb(:search)
end

get '/show/:name' do
  "Good day to you, #{params['name']}"
end

# rubocop:disable Style/BlockComments
=begin
  @files = Dir.glob('public/*')
              .filter { |file| File.file?(file) }
              .map { |file| File.basename(file) }.sort
  reversed = params['reverse'] || false
  puts "Reversed is: #{reversed}"
  @files.reverse! if reversed == 'true'
  # erb(:file_index)
=end
# rubocop:enable Style/BlockComments
