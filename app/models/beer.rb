class Beer < ApplicationRecord
    belongs_to :brewery
    has_many :users, through: :reviews

    def create_new(params)
        @brewery_id = Brewery.find_or_create_by(name: params['brewery']).id
        @beer = self.new(
            name: params['name'],
            style: params['style'],
            abv: params['abv'],
            ibu: params['ibu'],
            rating: params['rating'],
            img_url: params['img_url'],
            brewery_id: @brewery_id
        )
        byebug
        # @beer.save
        # @beer
    end     
end
