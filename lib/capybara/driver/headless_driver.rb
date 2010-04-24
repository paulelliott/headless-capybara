require 'harmony'
require 'nokogiri'

class Capybara::Driver::Headless < Capybara::Driver::Base

  class Node < Capybara::Node

    def text
      node.text
    end

    def [](name)
      node[name.to_s]
    end

    def set(value)
      node['value'] = value
    end

    def tag_name
      node.node_name
    end

    def visible?
      node.xpath("./ancestor-or-self::*[contains(@style, 'display:none') or contains(@style, 'display: none')]").size == 0
    end

  private

    def all_unfiltered(locator)
      driver.find(node.xpath(locator).map { |n| n.path }.join(' | '))
    end

  end

  attr_reader :app, :rack_server, :page

  def initialize(app)
    @app = app
    @rack_server = Capybara::Server.new(@app)
    @rack_server.boot if Capybara.run_server
  end

  def visit(path)
    @html = @body = nil
    @page = Harmony::Page.fetch(url(path))
  end

  def body
    @body ||= page.to_html
  end

  def html
    @html ||= Nokogiri::HTML(body)
  end

  def current_url
    page.window.location
  end

  def find(selector)
    html.xpath(selector).map { |node| Node.new(self, node) }
  end

  def evaluate_script(script)
    page.x(script)
  end

private

  def url(path)
    rack_server.url(path)
  end

  ###OLD IMPLEMENTATION
  def click(selector)
    page.xw("$('#{selector}').click();")
  end

  def element(selector)
    page.x("$('#{selector}').text();")
  end

  private

  def ajax_setup(page)
    page.x %<
      $.ajaxSetup({
        beforeSend: function(xhr) {
          xhr.open(this.type, 'http://localhost:3001' + this.url, this.async);
        }
      });
    >
  end

end
