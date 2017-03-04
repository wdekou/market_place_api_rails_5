class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :created_at, :updated_at, :auth_token
  has_many :products
  #link(:self) { user_url(object)}
end
