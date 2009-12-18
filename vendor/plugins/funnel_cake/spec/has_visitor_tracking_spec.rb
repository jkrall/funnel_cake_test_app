require 'ostruct'
require File.dirname(__FILE__) + '/spec_helper'

describe "for a controller that uses has_visitor_tracking" do
  class Analytics::Visitor < ActiveRecord::Base; end
  class TestController < ActionController::Base
    has_visitor_tracking
    attr_accessor :cookies
    def initialize
      super
      @cookies = {}
    end
  end

  before(:each) do
    @controller = TestController.new
  end

  describe "in the track_visitor_as_user before_filter" do
    before(:each) do
      @controller.stub!(:ignore_visitor?).and_return(false)
      @controller.stub!(:internal_visitor?).and_return(false)
    end

    describe "and this is not an internal user" do
      it "should check if this is an admin/internal user" do
        @controller.should_receive(:internal_visitor?).and_return(false)
        @controller.should_receive(:ignore_visitor?).and_return(false)
        @controller.track_visitor_as_user
      end
      it "should set the cookie to a new random hash" do
        randomval = '5'
        FunnelCake::RandomId.should_receive(:generate).and_return(randomval)
        @controller.track_visitor_as_user
        @controller.cookies.should == {:transfs_ut=>{:value=>randomval}}
      end
      it "should create a new Analytics::Visitor" do
        randomval = '5'
        FunnelCake::RandomId.should_receive(:generate).and_return(randomval)
        Analytics::Visitor.should_receive(:create).with(:key=>randomval).and_return(OpenStruct.new(:key=>randomval))
        @controller.track_visitor_as_user
      end
    end
    describe "and this is an internal user" do
      it "should do nothing if :internal_visitor? is true" do
        @controller.should_receive(:internal_visitor?).and_return(true)
        FunnelCake::RandomId.should_not_receive(:generate)
        Analytics::Visitor.should_not_receive(:create)
        @controller.track_visitor_as_user
      end
      it "should do nothing if :ignore_visitor? is true" do
        @controller.should_receive(:ignore_visitor?).and_return(true)
        FunnelCake::RandomId.should_not_receive(:generate)
        Analytics::Visitor.should_not_receive(:create)
        @controller.track_visitor_as_user
      end
    end
  end

  describe "when logging a funnel event" do
    before(:each) do
      @logger = mock('logger')
      @logger.stub!(:debug)
      @controller.stub!(:logger).and_return(@logger)
    end
    describe "if a user is logged in" do
      before(:each) do
        @controller.stub!(:internal_visitor?).and_return(false)
        @controller.stub!(:ignore_visitor?).and_return(false)
        @current_user = mock('User')
        @current_user.stub!(:log_funnel_event)
        @controller.stub!(:logged_in?).and_return(true)
        @controller.stub!(:current_user).and_return(@current_user)
      end
      it "should call log_funnel_event on the user" do
        @current_user.should_receive(:log_funnel_event)
        @controller.log_funnel_event(:test)
      end
    end
    describe "if no user is logged in" do
      before(:each) do
        @controller.stub!(:internal_visitor?).and_return(false)
        @controller.stub!(:ignore_visitor?).and_return(false)
        @current_visitor = mock('Analytics::Visitor')
        @current_visitor.stub!(:log_funnel_event)
        @controller.stub!(:logged_in?).and_return(false)
        @controller.stub!(:current_visitor).and_return(@current_visitor)
      end
      it "should call log_funnel_event on the Analytics::Visitor" do
        @current_visitor.should_receive(:log_funnel_event)
        @controller.log_funnel_event(:test)
      end
    end
    describe "if this is an admin user" do
      before(:each) do
        @controller.stub!(:internal_visitor?).and_return(false)
        @controller.stub!(:ignore_visitor?).and_return(false)
      end
      it "should do nothing if :internal_visitor? is true" do
        @controller.should_receive(:internal_visitor?).and_return(true)
        @controller.should_not_receive(:logged_in?)
        @controller.should_not_receive(:current_visitor)
        @controller.log_funnel_event(:test)
      end
      it "should do nothing if :ignore_visitor? is true" do
        @controller.should_receive(:ignore_visitor?).and_return(true)
        @controller.should_not_receive(:logged_in?)
        @controller.should_not_receive(:current_visitor)
        @controller.log_funnel_event(:test)
      end
    end
  end

  describe "when logging a page visit event" do
    it "should call the log_funnel_event method, with :url filled out automatically" do
      @controller.stub!(:request).and_return(OpenStruct.new(:request_uri=>"url"))
      @controller.should_receive(:log_funnel_event).with(:view_page, {:url=>"url"})
      @controller.log_funnel_page_visit
    end
  end

  describe "when syncing a visitor as a user" do
    describe "if there is a current user" do
      before(:each) do
        @current_user = mock('current_user')
        @controller.stub!(:logged_in?).and_return(true)
        @controller.stub!(:current_user).and_return(@current_user)
      end
      it "should set the user_id of the current Analytics::Visitor to the current user id" do
        @controller.should_receive(:logged_in?).and_return(true)
        @controller.should_receive(:current_user).and_return(@current_user)
        visitor = mock('current_visitor')
        visitor.should_receive(:user=).with(@current_user)
        @controller.should_receive(:current_visitor).any_number_of_times.and_return(visitor)
        visitor.should_receive(:save)
        @controller.sync_funnel_visitor
      end
    end
    describe "if there is no current user" do
      before(:each) do
        @current_user = mock('current_user')
        @controller.stub!(:logged_in?).and_return(false)
      end
      it "should do nothing" do
        @controller.should_receive(:logged_in?).and_return(false)
        @controller.should_not_receive(:current_user)
        @controller.should_not_receive(:current_visitor)
        @controller.sync_funnel_visitor
      end
    end
  end


end
