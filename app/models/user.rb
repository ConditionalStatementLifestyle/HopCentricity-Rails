class User < ApplicationRecord
    has_many :beers, through: :reviews
end
