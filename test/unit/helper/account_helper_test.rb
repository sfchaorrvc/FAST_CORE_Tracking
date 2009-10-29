require 'test_helper'

class AccountHelperTest < ActionView::TestCase
  context "Select list for accounts" do
    setup do
      stub(Account).all {[]}
    end

    should "have correct id for javascript" do
      assert_match 'select id="search_account_id_equals"', select_account({})
    end

    should "have an All option" do
      assert_match '<option value="">All</option>', select_account({})
    end

    should "include all accounts" do
      mock(Account).all{[Factory.build(:account, :id => 1, :company => 'Company')]}
      assert_match '<option value="1">Company</option>', select_account({})
    end

    should "select selected account" do
      mock(Account).all{[Factory.build(:account, :id => 1, :company => 'Company')]}
      assert_match '<option value="1" selected="selected">Company</option>', select_account({:account_id_equals => "1"})
    end
    
    should "select Unprovisioned" do
      assert_match '<option value="0" selected="selected">Unprovisioned</option>', select_account({:account_id_equals => "0"})
    end
    
    should "include an Unprovisioned option" do
      assert_match '<option value="0">Unprovisioned</option>', select_account({})
    end
    
    should "have label" do
      assert_match '<label for="search_account_id_equals">', select_account({})
    end
    
    should "provide list without Unprovisioned" do
      assert_no_match %r(<option value="0">Unprovisioned</option>), select_account({}, false)
    end
  end
end