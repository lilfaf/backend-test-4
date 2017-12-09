require 'test_helper'

class CallsControllerTest < ActionDispatch::IntegrationTest
  test '#index should render calls' do
    get calls_url
    assert_response :success
    assert_template :index
    assert_equal assigns(:calls), Call.all
  end

  test '#webhook' do
    post webhook_calls_url
    assert_response :success
  end

  test '#voicemail' do
    post voicemail_calls_url
    assert_response :no_content
  end

  test '#status' do
    post status_calls_url
    assert_response :no_content
  end

  test '#error' do
    post error_calls_url
    assert_response :no_content
  end
end
