class ReviewSerializer < ActiveModel::Serializer
  attributes :id, :rating, :content, :beer, :user
end
