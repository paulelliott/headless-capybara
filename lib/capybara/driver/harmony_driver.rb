class Capybara::Driver::Harmony < Capybara::Driver::Base

  class Node < Capybara::Node

  end

  attr_accessor :page
  class << self
    alias fetch new
  end

  def initialize(path)
    @page = h_visit(path)
  end

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

  def h_visit(path)
    Harmony::Page.fetch("http://localhost:3001#{path}").
      tap { |page| ajax_setup(page) }
  end

end
