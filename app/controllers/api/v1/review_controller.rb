class Api::V1::ReviewController < ApplicationController

    def user_reviews
        @user = User.find_by(email: params['email'])
        @reviews = Review.where(user_id: @user.id)
        render json: @reviews
    end 

    def create
        if params['beerId'] == nil
            if Beer.find_by(name: params['beer']) == nil
                brewery_id = Brewery.find_or_create_by(name: params['brewery'].downcase).id
                @beer = Beer.new(
                    name: params['beer'].downcase,
                    style: params['style'],
                    abv: params['abv'].to_f,
                    ibu: params['ibu'].to_f,
                    rating: params['rating'].to_f,
                    img_url: params['img_url'],
                    brewery_id: brewery_id
                )             
                @beer.save
            end
        else 
            @beer = Beer.find(params['beerId'])
        end 
        @user = User.find_by(email: params['email'])
        @review = Review.new(
            rating: params['userRating'].to_f,
            content: params['content'],
            user_id: @user.id,
            beer_id: @beer.id
        )
        @review.save
        render json: @review
    end

    def update 
        @review = Review.find(params['id'])
        @review.update(content: params['content'], rating: params['rating'])
        @review.save
        render json: @review
    end

    def destroy 
        @review = Review.find(params['id'])
        @review.destroy
    end

end
