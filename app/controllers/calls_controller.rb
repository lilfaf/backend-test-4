require 'twilio_responder'

class CallsController < ApplicationController
  skip_before_action :verify_authenticity_token, except: :index

  def index
    @calls = Call.all
  end

  def webhook
    render xml: TwilioResponder.response(:instructions)
  end

  def voicemail; end

  def status; end

  def error; end
end
