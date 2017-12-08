class Call < ApplicationRecord
  validates :sid, :from, :to, :status, presence: true

  enum status: %i(ringing in_progress completed)

  def self.from_twilio(params)
    where(sid: params[:call_sid]).first_or_create do |call|
      call.sid = params[:call_sid]
      call.from = params[:from]
      call.to = params[:to]
      call.direction = params[:direction]
      call.save!
    end
  end
end
