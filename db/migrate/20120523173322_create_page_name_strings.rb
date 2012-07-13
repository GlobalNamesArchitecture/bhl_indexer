class CreatePageNameStrings < ActiveRecord::Migration
  def up
    execute "CREATE TABLE `page_name_strings` (
      `page_id` varchar(255) NOT NULL,
      `name_string_id` int(11) NOT NULL,
      `name_offset_start` int(11) NOT NULL,
      `name_offset_end` int(11) NOT NULL,
      `ends_next_page` tinyint DEFAULT 0,
      `created_at` datetime DEFAULT NULL,
      `updated_at` datetime DEFAULT NULL,
      PRIMARY KEY (`page_id`,`name_string_id`, `name_offset_start`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci"
  end

  def down
    drop_table :page_name_strings
  end
end
    
