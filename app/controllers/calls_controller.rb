require 'twilio_responder'

class CallsController < ApplicationController
  skip_before_action :verify_authenticity_token, except: :index
  around_action :set_locale, only: :webhook

  def index
    @calls = Call.all
  end

  # POST /webhook
  # Main endpoint that handles calls flow
  #
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

  # POST /voicemail
  # Persist recording informations
  #
  def voicemail
    attributes = call_params.slice(:recording_url, :recording_duration)
    call.update_attributes(attributes)
  end

  # POST /status
  # Transition status to completed and set duration
  #
  def status
    call.complete(call_params)
  end

  # POST /error
  # Called when error ocurred on twilio
  #
  def error
    logger.error("Call #{call.sid} failed !")
  end

  private

  def call
    @call ||= Call.find_by!(sid: call_params[:call_sid])
  end

  # Permits params and converts camel cased keys to underscored symbols
  def call_params
    @call_params ||= params.permit!.to_h.transform_keys do |key|
      key.underscore.to_sym
    end
  end

  # Set locale based on caller country or fallback to english
  def set_locale
    country = call_params[:caller_country]&.downcase&.to_sym
    I18n.with_locale(country || I18n.default_locale) do
      yield if block_given?
    end
  end
end
