require 'test_helper'

class AuthenticatedSystemTest < ActiveSupport::TestCase
  
require 'authenticated_system'
  
  # Replace this with your real tests.
  def test_current_user	
    self.extend AuthenticatedSystem
    assert_equal true, authorized?
	end
  
 

end

