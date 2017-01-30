class SessionsController < ApplicationController
  def new
    # Create request_token
    # Save request_token to db
    # Set request_token to sessions
    # Redirect to twitter
  end

  def create
    # validate request_token
    # Get request_token from DB
    # Exchange for access_token
    # Get user profile
    # Save user to DB
    # Set user session
    # Redirect to origin
  end

  def destroy
    # destroy user session
    # redirect to homepage
  end
end
