require File.dirname(__FILE__) + '/../test_helper'

class OauthTokenTest < ActiveSupport::TestCase
  api_fixtures

  ##
  # check that after calling invalidate! on a token, it is invalid.
  def test_token_invalidation
    tok = OauthToken.new
    assert_equal false, tok.invalidated?, "Token should be created valid."
    tok.invalidate!
    assert_equal true, tok.invalidated?, "Token should now be invalid."
  end

  ##
  # check that an authorized token is authorised and can be invalidated
  def test_token_authorisation
    tok = RequestToken.create :client_application => client_applications(:oauth_web_app)
    assert_equal false, tok.authorized?, "Token should be created unauthorised."
    tok.authorize!(users(:public_user))
    assert_equal true, tok.authorized?, "Token should now be authorised."
    tok.invalidate!
    assert_equal false, tok.authorized?, "Token should now be invalid."
  end

  ##
  # test that tokens can't be found unless they're authorised
  def test_find_token
    tok = client_applications(:oauth_web_app).create_request_token
    assert_equal false, tok.authorized?, "Token should be created unauthorised."
    assert_equal nil, OauthToken.find_token(tok.token), "Shouldn't be able to find unauthorised token"
    tok.authorize!(users(:public_user))
    assert_equal true, tok.authorized?, "Token should now be authorised."
    assert_not_equal nil, OauthToken.find_token(tok.token), "Should be able to find authorised token"
  end

end
