class TwilioResponder
  attr_accessor :language

  MY_PHONE_NUMBER = '+33676667241'.freeze

  def self.response(name)
    TwilioResponder.new.send(name.to_sym).to_s
  end

  def initialize
    @language = I18n.locale || :fr
  end

  def instructions
    Twilio::TwiML::VoiceResponse.new do |r|
      r.say I18n.t('twilio.responses.hello'), language: language
      r.gather(timeout: 5.minutes, num_digits: 1) do |gather|
        gather.say I18n.t('twilio.responses.instructions'), language: language
      end
    end
  end

  def misunderstood
    Twilio::TwiML::VoiceResponse.new do |r|
      r.say I18n.t('twilio.responses.misunderstood'), language: language
      r.gather(timeout: 5.minutes, num_digits: 1) do |gather|
        gather.say I18n.t('twilio.responses.instructions'), language: language
      end
    end
  end

  def forward
    Twilio::TwiML::VoiceResponse.new do |r|
      r.say I18n.t('twilio.responses.forwarding'), language: language
      r.dial do |dial|
        dial.number MY_PHONE_NUMBER,
                    status_callback: Rails.application.routes.url_helpers.status_calls_url
      end
    end
  end

  def leave_voicemail
    Twilio::TwiML::VoiceResponse.new do |r|
      r.say I18n.t('twilio.responses.leave_voicemail'), language: language
      r.record recording_status_callback: Rails.application.routes.url_helpers.voicemail_calls_url
    end
  end
end
