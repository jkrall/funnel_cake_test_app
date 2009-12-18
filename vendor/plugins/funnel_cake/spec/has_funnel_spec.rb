require 'rubygems'
require 'active_record'
require 'action_controller'
require File.dirname(__FILE__) + '/../init'

module FunnelCake::UserStates
  def initialize_states
    # do nothing
  end
end

describe "using has_funnel on a User model" do
  class TestUser < ActiveRecord::Base
    set_table_name :users
  end
  class Analytics::Event < ActiveRecord::Base
  end
  class Analytics::Visitor < ActiveRecord::Base
  end

  before(:each) do
    TestUser.stub!(:acts_as_funnel_state_machine)
    TestUser.stub!(:has_many)
    TestUser.stub!(:state)
    TestUser.stub!(:initialize_states)
    Analytics::Visitor.stub!(:acts_as_funnel_state_machine)
    Analytics::Visitor.stub!(:state)
    Analytics::Visitor.stub!(:initialize_states)
    Analytics::Visitor.stub!(:has_one)
  end
  describe "for the User class" do
    it "should add the association for funnel events" do
      TestUser.should_receive(:has_many).with(:events, {:class_name=>"Analytics::Event"})
      TestUser.send(:has_funnel)
    end
    it "should add the acts_as_state_machine directive" do
      TestUser.should_receive(:acts_as_funnel_state_machine).with(hash_including(:log_transitions=>true, :validate_on_transitions=>false))
      TestUser.send(:has_funnel)
    end
    it "should add the :unknown state" do
      TestUser.should_receive(:state).with(:unknown)
      TestUser.send(:has_funnel)
    end
    it "should initialize the other states" do
      TestUser.should_receive(:initialize_states)
      TestUser.send(:has_funnel)
    end
    describe "when creating funnel events" do
      it "should wrap the state_machine event method" do
        p = Proc.new {transitions :from, :to}
        TestUser.should_receive(:event).with(:funnel_test, p)
        TestUser.send(:event, :test, &p)
      end
    end
    it "should add the association for funnel visitors" do
      TestUser.should_receive(:has_many).with(:visitors, {:class_name=>"Analytics::Visitor"})
      TestUser.send(:has_funnel, :visitor_class_name=>"Analytics::Visitor")
    end
  end
  describe "for the Analytics::Visitor class" do
    it "should add the acts_as_state_machine directive" do
      Analytics::Visitor.should_receive(:acts_as_funnel_state_machine).with(hash_including(:log_transitions=>true, :validate_on_transitions=>false))
      TestUser.send(:has_funnel)
    end
    it "should add the :unknown state" do
      Analytics::Visitor.should_receive(:state).with(:unknown)
      TestUser.send(:has_funnel)
    end
    it "should initialize the other states" do
      Analytics::Visitor.should_receive(:initialize_states)
      TestUser.send(:has_funnel)
    end
    it "should add the association for users" do
      Analytics::Visitor.should_receive(:belongs_to).with(:user, :class_name=>"TestUser", :foreign_key=>:user_id)
      TestUser.send(:has_funnel, :visitor_class_name=>"Analytics::Visitor")
    end
  end
end

describe "for instance methods on a acts_as_funnel model" do
  before(:each) do
    @user = TestUser.new
  end
  describe "when responding to a state_machine transition" do
    it "should create a new Analytics::Event" do
      @fe = mock('events')
      @fe.should_receive(:create).with(:from=>"from", :to=>"to", :name=>"event", :url=>"url")
      @user.should_receive(:events).and_return(@fe)
      @user.log_transition("from", "to", "event", {:url=>"url"}, {})
    end
  end
  describe "when performing a funnel event" do
    before(:each) do
      @user.stub!(:valid_events).and_return([:do_a, :do_b])
    end
    it "should log an error and return if the event is not valid for the current state" do
      @user.should_receive(:valid_events).and_return([:do_c, :do_d])
      @user.stub!(:current_state).and_return([:state_a])
      logger = mock('logger')
      logger.stub!(:debug)
      @user.stub!(:logger).and_return(logger)
      @user.should_not_receive(:do_b!)
      @user.log_event(:do_b, {:url=>"url"})
    end
    it "should call send() with the appropriate event name" do
      @user.should_receive(:do_b!)
      @user.log_event(:do_b, {:url=>"url"})
    end
  end
end

