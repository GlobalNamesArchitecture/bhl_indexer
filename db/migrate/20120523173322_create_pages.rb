class CreatePages < ActiveRecord::Migration
  def up
    execute "CREATE TABLE `page_names` (
      `page_id` varchar(255) NOT NULL,
      `title_id` varchar(255) NOT NULL,
      `name_string_id` int(11) NOT NULL,
      `name_offset_start` int(11) NOT NULL,
      `name_offset_end` int(11) NOT NULL,
      `created_at` datetime DEFAULT NULL,
      `updated_at` datetime DEFAULT NULL,
      PRIMARY KEY (`page_id`,`name_string_id`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci"
  end

  def down
    drop_table :page_names
  end
end
    
