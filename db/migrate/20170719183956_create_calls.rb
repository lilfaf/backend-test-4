class CreateCalls < ActiveRecord::Migration[5.1]
  def change
    create_table :calls do |t|
      t.string   :sid,    null: false, index: true
      t.string   :from,   null: false
      t.string   :to,     null: false
      t.integer  :status, null: false, default: 0
      t.integer  :duration
      t.string   :direction
      t.string   :recording_url
      t.integer  :recording_duration
      t.datetime :completed_at

      t.timestamps
    end
  end
end
