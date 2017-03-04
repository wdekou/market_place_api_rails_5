class OrderSerializer < ActiveModel::Serializer
  attributes :id
  belongs_to :user, serializer: UserSerializer
  has_many :placements, serializer: PlacementSerializer
  has_many :products, serializer: ProductSerializer
end
