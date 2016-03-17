require 'spec_helper'

describe "DbCharmer regression tests" do
  fixtures :categories, :posts, :categories_posts

  it "should allow forcing the connction even when using limit or all or to_a" do
    # Underlying bug was that merged scopes were losing the db_charmer variables
    Category.on_master.connection.should_not_receive(:select_all)
    Category.on_db(:slave01).connection.should_receive(:select_all).at_least(:once).and_call_original

    DbCharmer.force_slave_reads do
      cat = Category.first
      cat.posts.to_a.size.should == 2
      cat.posts.limit(1).where('1=0').size.should == 0
    end
  end
end
