# encoding: utf-8
class Tag < ActiveRecord::Base
  attr_accessible :name, :user_id, :popularity
end
