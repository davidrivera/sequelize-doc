class Post
  require 'redcarpet'
  require 'nokogiri'
  require './lib/misc/sequelize_renderer.rb'

  def self.renderer
    @@renderer ||= Redcarpet::Markdown.new(SequelizeRenderer, :fenced_code_blocks => true, :strikethrough => true)
  end

  def self.all
    Dir['views/blog/posts/*md'].map do |d|
      d.sub('views/blog/posts/', '')
    end.sort_by(&:to_i).map do |filename|
      Post.new(filename, markdown("blog/posts/#{filename.sub('.md', '')}".to_sym))
    end.reverse
  end

  def self.find_by_basename(basename)
    Post.all.detect do |post|
      post.basename == basename
    end
  end

  def initialize(filename, content)
    @filename = filename
    @content  = content
  end

  def content
    @content
  end

  def teaser
    [content.match(/<\/h3>(.+?)<h4>/m), $1].last
  end

  def filename
    @filename
  end

  def basename
    filename.sub('.md', '')
  end

  def title
    [content.match(/<h3>(.*)<\/h3>/), $1].last
  end

  def url_fragment
    basename.sub("#{basename.to_i}-", "")
  end

  def teaser_image
    doc = to_nokogiri_doc
    doc.at_css('[data-source="flickr"]').to_html
  end

  def to_nokogiri_doc
    Nokogiri::HTML(content)
  end

private

  def self.markdown(s)
    content = if s.is_a?(Symbol)
      File.read("#{Dir.pwd}/views/#{s}.md")
    elsif s.is_a?(String)
      content
    end

    Post.renderer.render(content)
  end
end
