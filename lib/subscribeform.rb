require 'ohm'

class SubscribeForm < Ohm::Model

  attribute :api_key
  attribute :list_id

  index :api_key

  def validate
    assert_present :api_key
    assert_present :list_id
  end

end
