require 'ohm'

class SubscribeForm < Ohm::Model

  attribute :user_id
  attribute :page_id
  attribute :api_key
  attribute :list_id

  index :user_id
  index :page_id
  index :api_key
  index :list_id

  def validate
    assert_present :user_id
    assert_present :page_id
    assert_present :api_key
    assert_present :list_id
  end

end
