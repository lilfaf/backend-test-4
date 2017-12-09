class Call < ApplicationRecord
  include AASM

  validates :sid, :from, :to, :status, presence: true

  enum status: %i[ringing in_progress completed]

  aasm column: :status, enum: true do
    state :ringing, initial: true
    state :in_progress, :completed

    event :progress do
      transitions from: :ringing, to: :in_progress
    end

    event :complete do
      transitions from: :in_progress, to: :completed
      after do |params|
        update_attributes(
          duration: params[:call_duration],
          completed_at: Time.zone.now
        )
      end
    end
  end

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
