class StaticController < ApplicationController
  protect_from_forgery except: [:firebase_messaging_sw]

  def firebase_messaging_sw
    respond_to do |format|
      format.js { render file: '/public/firebase-messaging-sw.js.erb' }
    end
  end
end
