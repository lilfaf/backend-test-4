require 'test_helper'
require 'twilio_responder'

class TwilioResponderTest < ActiveSupport::TestCase
  test 'should returns instructions response' do
    response = TwilioResponder.response(:instructions)
    assert_includes response, I18n.t('twilio.responses.hello')
    assert_includes response, I18n.t('twilio.responses.instructions')
  end

  test 'should returns french response' do
    I18n.locale = :fr
    response = TwilioResponder.response(:instructions)
    assert_includes response, 'language="fr"'
  end

  test 'should returns misunderstood response' do
    response = TwilioResponder.response(:misunderstood)
    assert_includes response, I18n.t('twilio.responses.misunderstood')
    assert_includes response, I18n.t('twilio.responses.instructions')
  end

  test 'should returns forward response' do
    response = TwilioResponder.response(:forward)
    assert_includes response, I18n.t('twilio.responses.forwarding')
    assert_includes response, '<Number statusCallback="http://example.com/calls/status">+33619252256</Number>'
  end

  test 'should returns leave_voicemail response' do
    response = TwilioResponder.response(:leave_voicemail)
    assert_includes response, I18n.t('twilio.responses.leave_voicemail')
    assert_includes response, '<Record recordingStatusCallback="http://example.com/calls/voicemail"/>'
  end
end
