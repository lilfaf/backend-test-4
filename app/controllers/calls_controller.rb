class CallsController < ApplicationController
  def index
    @calls = Call.all
  end

  def webhook
  end

  def voicemail
  end

  def status
  end

  def error
  end
end
