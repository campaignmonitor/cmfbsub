require 'ohm'

class SubscribeForm < Ohm::Model

  attribute :user_id
  attribute :page_id
  attribute :api_key
  attribute :list_id
  attribute :intro_message
  attribute :thanks_message

  index :user_id
  index :page_id
  index :api_key
  index :list_id

  def validate
    assert_present :user_id
    assert_present :page_id
    assert_present :api_key
    assert_present :list_id
    assert_present :intro_message
    assert_present :thanks_message
  end

  def to_hash
    super.merge(:user_id => user_id, :page_id => page_id, 
      :api_key => api_key, :list_id => list_id,
      :intro_message => intro_message, :thanks_message => thanks_message)
  end

end
