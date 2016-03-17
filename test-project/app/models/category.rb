class Category < ActiveRecord::Base
  has_and_belongs_to_many :posts
  db_magic Post::DB_MAGIC_DEFAULT_PARAMS
end
