require 'test_helper'

class CallTest < ActiveSupport::TestCase
  ### Schema
  #
  should have_db_column(:sid).with_options(null: false)
  should have_db_column(:from).with_options(null: false)
  should have_db_column(:to).with_options(null: false)
  should have_db_column(:status).with_options(null: false)
  should have_db_column(:duration)
  should have_db_column(:direction)
  should have_db_index(:sid)

  ### Validations
  #
  should validate_presence_of(:sid)
  should validate_presence_of(:from)
  should validate_presence_of(:to)
  should validate_presence_of(:status)

  ### Class methods
  #
  test '.from_twilio founds call or creates new record' do
    # 1 - Returns existing fixture call
    assert_difference 'Call.count', 0 do
      Call.from_twilio(call_sid: '123')
    end

    # 2 - Returns new call
    params = {
      call_sid: '456',
      from: '+33666666666',
      to: '+33999999999'
    }

    assert_difference 'Call.count', 1 do
      Call.from_twilio(params)
    end

    call = Call.last
    assert_equal call.sid, params[:call_sid]
    assert_equal call.from, params[:from]
    assert_equal call.to, params[:to]
  end
end
