class User < ApplicationRecord
    has_secure_password
    has_many :beers, through: :reviews
end
