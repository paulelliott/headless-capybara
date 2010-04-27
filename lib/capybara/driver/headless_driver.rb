require 'harmony'

class Capybara::Driver::Headless < Capybara::Driver::Base

  JQUERY = File.open(File.expand_path(File.join('lib','capybara','jquery-1.4.2.min.js'))).read

  class Node < Capybara::Node

    def text
      driver.page.x(%<CHD.queried_objects[#{node}].innerText>)
    end

    def [](name)
      name = name.to_s
      name = 'className' if name == 'class'
      driver.page.x(%<CHD.queried_objects[#{node}].#{name}>)
    end

    def set(value)
      driver.page.x(%<CHD.queried_objects[#{node}].value = "#{value}">)
    end

    def tag_name
      driver.page.x(%<CHD.queried_objects[#{node}].tagName>).downcase
    end

    def visible?
      driver.page.x(%<
        var node = $HC(CHD.queried_objects[#{node}]);
        node.is(':visible') && node.parents(':hidden').length == 0
      >)
    end

    def drag_to(element)
      driver.page.x(%<
        CHD.queried_objects[#{node}].onmousedown();
        CHD.queried_objects[#{element.node}].onmousemove();
        CHD.queried_objects[#{element.node}].onmouseup();
      >)
    end

  private

    def all_unfiltered(locator)
      driver.page.x(%<
        CHD.find_by_xpath('#{locator}', CHD.queried_objects[#{node}])
      >).split(',').map{ |key| Node.new(self, key) }
    end

  end

  attr_reader :app, :rack_server, :page

  def initialize(app)
    @app = app
    @rack_server = Capybara::Server.new(@app)
    @rack_server.boot if Capybara.run_server
  end

  def visit(path)
    clear_memoized
    @page = Harmony::Page.fetch(url(path))
    page.x(%<
      var CHD = {
        object_count: 0,
        queried_objects: {},
        find_by_xpath: function(selector, context) {
          if (context == null) { context = document; }
          var response = [];
          var q = document.evaluate(selector, context, null, XPathResult.ANY_TYPE, null)
          var obj = q.iterateNext();
          while (obj) {
            response.push(CHD.object_count);
            CHD.queried_objects[CHD.object_count] = obj;
            CHD.object_count += 1;
            obj = q.iterateNext();
          }
          return response.join(',');
        }
      };
    >)
    page.x(JQUERY)
  end

  def body
    @body ||= page.to_html
  end
  alias :source :body
  alias :html :body

  def current_url
    page.window.location.to_s
  end

  def find(selector)
    page.x(%<CHD.find_by_xpath('#{selector}')>).split(',').map{ |key| Node.new(self, key) }
  end

  def evaluate_script(script)
    clear_memoized
    page.x(script)
  end

private

  def url(path)
    rack_server.url(path)
  end

  def clear_memoized
    @body = nil
  end

end
