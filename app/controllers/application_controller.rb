# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password

  layout 'standard'

  has_visitor_tracking :cookie_name=>:transfs_ut

  def current_user
    nil
  end
 
  def logged_in?
    false
  end

  before_filter :setup_includes
  def setup_includes
    @stylesheets = [:admin]
    @javascripts = [:admin]
  end

end
