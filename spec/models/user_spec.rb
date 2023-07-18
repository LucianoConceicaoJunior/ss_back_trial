require 'rails_helper'

RSpec.describe User, type: :model do
  it 'must be created with API Key'  do
    user = User.create! name: 'User1'
    expect(user.api_key).not_to be_empty
  end
end
