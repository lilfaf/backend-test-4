require 'twilio_responder'

class CallsController < ApplicationController
  skip_before_action :verify_authenticity_token, except: :index

  def index
    @calls = Call.all
  end

  def webhook
    # Loads or create call
    call = Call.from_twilio(call_params)

    # Transition call status from ringing to in progress
    call.progress! if call_params[:call_status] == 'in-progress'

    # Early return with instructions on ringing call
    return render xml: TwilioResponder.response(:instructions) if call.ringing?

    # Do nothing unless call is in progress. Ignore hangup status.
    return head :no_content unless call.in_progress?

    # Returns twilio response based on pressed digit
    xml = case call_params[:digits]
          when '1'
            TwilioResponder.response(:forward)
          when '2'
            TwilioResponder.response(:leave_voicemail)
          else
            TwilioResponder.response(:misunderstood)
          end

    render xml: xml
  end

  def voicemail; end

  def status; end

  def error; end

  private

  def call_params
    @call_params ||= params.permit!.to_h.transform_keys do |key|
      key.underscore.to_sym
    end
  end
end
