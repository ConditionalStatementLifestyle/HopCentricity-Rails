class BeerSerializer < ActiveModel::Serializer
  attributes :id, :name, :style, :abv, :ibu, :rating, :img_url, :brewery
end
