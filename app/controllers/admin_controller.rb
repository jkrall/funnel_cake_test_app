class AdminController < ApplicationController

  def index
    log_funnel_page_visit
  end

  def test_a
    log_funnel_page_visit
  end

  def test_b
    log_funnel_page_visit
  end

  def test_c
    log_funnel_page_visit
  end

end
