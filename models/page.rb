class Page < ActiveRecord::Base
  # primary_key = :page_id
  belongs_to :title
  has_many :page_name_strings
  has_many :name_strings, :through => :page_name_strings
end
