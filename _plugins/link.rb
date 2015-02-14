module Jekyll
  class LinkTag < Liquid::Tag

    def initialize(tag_name, text, tokens)
      super

      @attributes = {}
      text.scan(::Liquid::TagAttributes) do |key, value|
        @attributes[key] = value
      end
    end

    def render(context)
        url = @attributes['href']
        if @attributes.has_key?('title')
          title = @attributes['title']
        else
          title = url
        end

        "<div class=\"links\"><a href=\"#{url}\">#{title}</a></div>"
    end
  end
end

Liquid::Template.register_tag('link', Jekyll::LinkTag)
