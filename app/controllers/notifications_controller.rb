# frozen_string_literal: true

class NotificationsController < ApplicationController
  before_action :enable_test

  def index
    @subscription = current_subscription || Subscription.new
    @topics = [
      {
        id: :deeds,
        text: 'Tell me about new Deeds'
      }
    ]

    return unless current_user&.admin? || @test_push

    @topics << {
      id: :test,
      text: 'Tell me about test notifications'
    }
  end

  private

  def enable_test
    cookies[:test_push] = true if params[:test] == 'push'

    @test_push = cookies[:test_push]
  end
end
