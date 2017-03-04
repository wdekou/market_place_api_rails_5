class ProductSerializer < ActiveModel::Serializer
  attributes :id, :title, :price, :published
  belongs_to :user, serializer: UserSerializer
end
