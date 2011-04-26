class Form
  include DataMapper::Resource

  property :id, Serial
  property :user_id, String, :required => true
  property :page_id, String, :required => true, :key => true
  property :api_key, String, :required => true
  property :list_id, String, :required => true
  property :intro_message, String, :required => true, :length => 0..250
  property :thanks_message, String, :required => true, :length => 0..250

  has n, :custom_fields
end

class CustomField
  include DataMapper::Resource

  property :id, Serial
  property :name, String, :required => true
  property :field_key, String, :required => true
  property :data_type, String, :required => true
  property :field_options, String, :length => 0..5000 # Comma-delimited options

  belongs_to :form
end
