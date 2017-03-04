class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :created_at, :updated_at, :auth_token, :product_ids
  has_many :products, serializer: ProductSerializer
  #embed :ids
  #link(:self) { user_url(object)}
end
