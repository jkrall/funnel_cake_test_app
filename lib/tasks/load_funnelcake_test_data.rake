require 'active_record'

class TempEvent < ActiveRecord::Base
  def self.table_name
    "tfs_development.funnelcake_events"
  end
  belongs_to :visitor, :class_name=>'TempVisitor', :foreign_key=>:visitor_id
end
class TempVisitor < ActiveRecord::Base
  def self.table_name
    "tfs_development.funnelcake_visitors"
  end
  has_many :events, :class_name=>'TempEvent', :dependent=>:destroy, :foreign_key=>:visitor_id
end

namespace :funnel_cake do
  desc "Load test data"
  task :load_test_data => :environment do
    MongoMapper.connection = Mongo::Connection.new('127.0.0.1', 27017, :logger=>Logger.new(STDOUT))
    MongoMapper.database = 'funnelcake'

    TempVisitor.find_in_batches do |batch|
      batch.each do |v|
        visitor = Analytics::Visitor.create({
          :user_id=>v.user_id,
          :created_at=>v.created_at,
          :updated_at=>v.updated_at,
          :state=>v.state,
          :ip=>v.ip,
          :key=>v.key,
        })
        v.events.each do |e|
          visitor.events << Analytics::Event.new({
            :to=>e.to,
            :from=>e.from,
            :created_at=>e.created_at,
            :url=>e.url,
            :name=>e.name,
            :referer=>e.referer,
            :user_agent=>e.user_agent,
          })
        end
        visitor.save
      end
    end

  end
end