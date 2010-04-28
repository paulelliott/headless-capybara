require 'johnson/tracemonkey'
require 'envjs/runtime'

class Capybara::Driver::Headless < Capybara::Driver::Base

  class Node < Capybara::Node

    def text
      node.innerText
    end

    def [](name)
      name = name.to_s
      name = 'className' if name == 'class'
      node[name]
    end

    def set(value)
      if %w(radio checkbox).include? node['type']
        trigger(:click)
      elsif tag_name == 'textarea'
        node.innerHTML = value
      else
        node.value = value || ''
      end
    end

    def select(option)
      options = all_unfiltered("//option[text()=#{Capybara::XPath.escape(option)}]") ||
        all_unfiltered("//option[contains(.,#{Capybara::XPath.escape(option)}]")
     options[0].node.selected = true
    rescue Exception
      raise Capybara::OptionNotFound, "Option '#{option}' not found in select '#{node.name}'"
    end

    def tag_name
      node.tagName.downcase
    end

    def visible?
      all_unfiltered("./ancestor-or-self::*[contains(@style, 'display:none') or contains(@style, 'display: none')]").empty?
    end

    def drag_to(element)
      trigger(:mousedown)
      element.trigger(:mousemove)
      element.trigger(:mouseup)
    end

    def click
      trigger(:click)
    end

    def trigger(event)
      node.dispatchEvent create_event(event)
    end

    private

    def all_unfiltered(locator)
      driver.find(locator, node)
    end

    def create_event(event)
      driver.document.createEvent('MouseEvent').tap do |e|
        e.initEvent(event.to_s, true, true)
      end
    end

  end

  attr_reader :app, :rack_server, :page

  def initialize(app)
    @app = app
    @rack_server = Capybara::Server.new(@app)
    @rack_server.boot if Capybara.run_server
  end

  def visit(path)
    window.location = rack_url(path)
  end

  def body
    window.document.innerHTML
  end
  alias :source :body
  alias :html :body

  def current_url
    window.location.to_s
  end

  def find(selector, context = window.document)
    elements = window.document.evaluate(selector, context, nil, window['XPathResult'].ANY_TYPE, nil)
    [].tap do |nodes|
      while element = elements.iterateNext do
        nodes << Node.new(self, element)
      end
    end
  end

  def evaluate_script(script)
    window.evaluate(script)
  end

  def document
    window.document
  end

  private

  BASE_RUNTIME = Johnson::Runtime.new :size => Integer(ENV["JOHNSON_HEAP_SIZE"] || 0x4000000)
  BASE_RUNTIME.extend(Envjs::Runtime)

  def window
    @window ||= BASE_RUNTIME.evaluate("window.open('about:blank')")
  end

  def rack_url(path)
    rack_server.url(path)
  end

end
