class Task < ActiveRecord::Base
  serialize :dependencies
end
