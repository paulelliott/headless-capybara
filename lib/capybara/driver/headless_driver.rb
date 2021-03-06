require 'johnson/tracemonkey'
require 'envjs/runtime'

class Capybara::Driver::Headless < Capybara::Driver::Base

  class Node < Capybara::Node

    def text
      node.innerText
    end

    def [](name)
      name = name.to_s
      case
      when name == 'class'
        node['className']
      when name == 'value'
        if tag_name == 'select' && node['multiple']
          all_unfiltered(".//option[@selected]").map { |option| option.node.value }
        else
          node.value
        end
      else
        node[name]
      end
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
      options = all_unfiltered(".//option[text()='#{option}']") +
        all_unfiltered(".//option[contains(.,'#{option}')]")
      if node.multiple
        options.each { |option| option.node.selected = true }
      else
        options.first.node.selected = true
      end
    rescue Exception
      raise Capybara::OptionNotFound, "Option '#{option}' not found in select '#{node.name}'"
    end

    def unselect(option)
      if node.multiple
        begin
          options = all_unfiltered(".//option[text()='#{option}']") ||
            all_unfiltered(".//option[contains(.,'#{option}')]")
          options.each { |option| option.node.selected = false }
          raise Exception if options.empty?
        rescue Exception
          raise Capybara::OptionNotFound, "Option '#{option}' not found in select '#{node.name}'"
        end
      else
        raise Capybara::UnselectNotAllowed, "Cannot unselect option '#{option}' from single select box."
      end
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

  attr_reader :rack_server

  def initialize(app)
    @rack_server = Capybara::Server.new(app)
    @rack_server.boot if Capybara.run_server
  end

  def visit(path)
    window.location = rack_server.url(path)
  end

  def body
    window.document.innerHTML
  end
  alias :html :body

  def source
    window.document.__original_text__
  end

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

  def wait?; true end

  def wait_until(max)
    fired, wait = *window["Envjs"].wait(-max*1000)
    raise Capybara::TimeoutError if !fired && wait.nil?
  end

  def has_shortcircuit_timeout?; true end

  class ResponseHeaders < Hash
    def [] key
      super[key.downcase]
    end
  end

  def response_headers; ResponseHeaders.new(document.__headers__) end

  private

  def runtime
    @@runtime ||= Johnson::Runtime.new(:size => Integer(ENV["JOHNSON_HEAP_SIZE"] || 0x8000000)).
      tap { |rt| rt.extend(Envjs::Runtime) }
  end

  def window
    @window ||= runtime.evaluate("window.open('about:blank')")
  end

end
