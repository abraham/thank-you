class SubscriptionsController < ApplicationController
  before_action :build_api
  before_action :require_subscription, except: [:create]
  before_action :require_token, only: [:create]

  def create
    info = @api.info(params[:subscription][:token])
    subscription = Subscription.find_or_create_by(token: params[:subscription][:token]) do |sub|
      sub.active_at = Time.now.utc
      sub.user = current_user
      sub.topics = topics_from_info(info)
    end

    if info && !subscription.new_record?
      session[:subscription_id] = subscription.id
      render json: subscription
    else
      render json: {}, status: 500
    end
  end

  def destroy
    current_subscription.destroy
    render json: {}
  end

  def show
    render json: current_subscription
  end

  def update
    subscription = current_subscription
    params[:subscription][:changes].each do |change|
      if change[:change] == 'add'
        result = @api.add_topic(current_subscription.token, change[:topic])
        subscription.topics << change[:topic] if result.status_code == 200
      elsif change[:change] == 'remove'
        result = @api.remove_topic(current_subscription.token, change[:topic])
        subscription.topics.delete(change[:topic]) if result.status_code == 200
      end
    end
    subscription.save
    render json: current_subscription
  end

  private

  def topics_from_info(info)
    (info.dig(:rel, :topics) || {}).keys
  end

  def valid_topic?(topic)
    ['deeds', 'test'].include?(topic)
  end

  def require_token
    render_forbidden_json unless params[:subscription] && params[:subscription][:token]
  end

  def require_subscription
    render_forbidden_json unless current_subscription
  end

  def build_api
    @api = GoogleInstanceId.new(Rails.application.secrets.firebase_messaging_key)
  end
end
