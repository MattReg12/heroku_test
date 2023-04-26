require "sinatra"
require "sinatra/reloader" if development?
require "tilt/erubis"

helpers do
  def strongify(hit, keyword)
    hit = hit.split(keyword)
    hit.first + "<strong>#{keyword}</strong>" + hit.last
  end
end

before do
  @contents = File.read("data/toc.txt").split("\n")
  @chapters = chapters.map { |chapter| chapter.split("\n\n") }
end

get "/" do
  erb :home
end

get "/chapters/:number" do
  @number = params['number']
  @chapter = File.read("data/chp#{@number}.txt").split("\n\n")
  erb :chapter
end

get '/search' do
  @keyword = params['query'] if params['query']
  @matches = matches(@keyword) if @keyword
  erb :search
end

not_found do
  redirect '/'
end

def chapters
  files = Dir.children('data') - ['toc.txt']
  files.sort_by! { |chp| chp.match(/\d+/).to_s.to_i }
  files.map do |file|
    File.read("data/#{file}")
  end
end

def matches(keyword)
  arr = @chapters.each_with_object([]).with_index do |(chapter, arr), i|
    paragraphs = chapter.select { |paragraph| paragraph.include?(keyword) }
    unless paragraphs.empty?
      paragraphs.map! { |paragraph| [paragraph, chapter.index(paragraph), i + 1] }
      arr << { @contents[i] => paragraphs }
    end
  end
  arr.empty? ? nil : arr
end


