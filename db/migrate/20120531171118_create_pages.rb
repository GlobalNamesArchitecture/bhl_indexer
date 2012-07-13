class CreatePages < ActiveRecord::Migration
  def up
    execute "CREATE TABLE `pages` (
      `id` varchar(255) NOT NULL,
      `title_id` varchar(255) NOT NULL,
      PRIMARY KEY (`id`),
      KEY `idx_pages_page_id` (`title_id`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci"
  end

  def down
    drop_table :pages
  end
end
    
