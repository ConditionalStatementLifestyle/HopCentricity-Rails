class AuthController < ApplicationController
  
  def login
    if is_authorized(params["token"])
      puts 'logged in'
      @user = User.find_or_create_by(email: params['email'])
      @user.username = params['username']
      @user.save
    else
      puts 'failed login'
    end
  end

  def is_authorized(token)
    validator = GoogleIDToken::Validator.new
    required_audience = '145472087581-5k6ima9vtqqfv31dbtpuces92hpqvd0o.apps.googleusercontent.com'
    optional_client_id = '145472087581-5k6ima9vtqqfv31dbtpuces92hpqvd0o.apps.googleusercontent.com'

    begin
      payload = validator.check(token, required_audience, optional_client_id)
      email = payload['email']
      if payload
        return true
      else
        return false
      end
      rescue GoogleIDToken::ValidationError => e
      puts "Cannot validate: #{e}"
    end
  end

end