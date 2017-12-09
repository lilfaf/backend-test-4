require 'test_helper'

class CallsControllerTest < ActionDispatch::IntegrationTest
  test '#index should render calls' do
    get calls_url
    assert_response :success
    assert_template :index
    assert_equal assigns(:calls), Call.all
  end

  test '#webhook when call ringing' do
    params = {
      'CallSid' => '123',
      'From' => '+33333333333',
      'To' => '+33666666666',
      'Direction' => 'inbound'
    }

    post webhook_calls_url(params)
    assert_response :success
    assert_includes response.body, I18n.t('twilio.responses.instructions')
  end

  test '#webhook when pressed digit misunderstood' do
    params = {
      'CallSid' => '123',
      'From' => '+33333333333',
      'To' => '+33666666666',
      'Direction' => 'inbound',
      'CallStatus' => 'in-progress',
      'Digits' => '3'
    }

    post webhook_calls_url(params)
    assert_response :success
    assert_includes response.body, I18n.t('twilio.responses.misunderstood')
  end

  test '#webhook when pressed 1' do
    params = {
      'CallSid' => '123',
      'From' => '+33333333333',
      'To' => '+33666666666',
      'Direction' => 'inbound',
      'CallStatus' => 'in-progress',
      'Digits' => '1'
    }

    post webhook_calls_url(params)
    assert_response :success
    assert_includes response.body, I18n.t('twilio.responses.forwarding')
  end

  test '#webhook when pressed 2' do
    params = {
      'CallSid' => '123',
      'From' => '+33333333333',
      'To' => '+33666666666',
      'Direction' => 'inbound',
      'CallStatus' => 'in-progress',
      'Digits' => '2'
    }

    post webhook_calls_url(params)
    assert_response :success
    assert_includes response.body, I18n.t('twilio.responses.leave_voicemail')
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
