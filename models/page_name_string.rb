class PageNameString < ActiveRecord::Base
  primary_keys = [:page_id, :name_string_id, :name_offset_start]
  belongs_to :name_string, :foreign_key => :name_string_id
end
