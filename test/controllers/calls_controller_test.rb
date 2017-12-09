require 'test_helper'

class CallsControllerTest < ActionDispatch::IntegrationTest
  base_params = {
    'CallSid' => '123',
    'From' => '+33333333333',
    'To' => '+33666666666',
    'Direction' => 'inbound'
  }

  test '#index should render calls' do
    get calls_url
    assert_response :success
    assert_template :index
    assert_equal assigns(:calls), Call.all
  end

  test '#webhook when call ringing' do
    post webhook_calls_url(base_params)
    assert_response :success
    assert_includes response.body, I18n.t('twilio.responses.instructions')
  end

  test '#webhook when pressed digit misunderstood' do
    params = base_params.merge(
      'CallStatus' => 'in-progress',
      'Digits' => '3'
    )

    post webhook_calls_url(params)
    assert_response :success
    assert_includes response.body, I18n.t('twilio.responses.misunderstood')
  end

  test '#webhook when pressed 1' do
    params = base_params.merge(
      'CallStatus' => 'in-progress',
      'Digits' => '1'
    )

    post webhook_calls_url(params)
    assert_response :success
    assert_includes response.body, I18n.t('twilio.responses.forwarding')
  end

  test '#webhook when pressed 2' do
    params = base_params.merge(
      'CallStatus' => 'in-progress',
      'Digits' => '2'
    )

    post webhook_calls_url(params)
    assert_response :success
    assert_includes response.body, I18n.t('twilio.responses.leave_voicemail')
  end

  test '#voicemail' do
    url = 'http://dummy.com/foobar'
    params = base_params.merge(
      'RecordingUrl' => url,
      'RecordingDuration' => '10'
    )

    post voicemail_calls_url(params)
    assert_response :no_content
    assert_equal Call.last.reload.recording_url, url
  end

  test '#status' do
    call = Call.first
    params = base_params.merge(
      'CallSid' => '456',
      'CallDuration' => 10,
      'CallStatus' => 'completed'
    )

    post status_calls_url(params)
    assert_response :no_content
    assert_equal call.reload.duration, 10
    assert_not_nil call.completed_at
  end

  test '#error' do
    post error_calls_url(base_params)
    assert_response :no_content
  end
end
