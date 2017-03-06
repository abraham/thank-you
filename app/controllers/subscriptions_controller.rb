class SubscriptionsController < ApplicationController
  before_action :find_token
  before_action :require_token

  def create
    render :nothing, status: 500 unless valid_topic?(params[:subscription][:topic])
    topic = @api.add_topic(@token, params[:subscription][:topic])
    if topic
      render json: { added: params[:subscription][:topic] }
    else
      render :nothing, status: 500
    end
  end

  def destroy
    render :nothing, status: 500 unless valid_topic?(params[:subscription][:topic])
    topic = @api.remove_topic(@token, params[:subscription][:topic])
    if topic
      render json: { removed: params[:subscription][:topic] }
    else
      render :nothing, status: 500
    end
  end

  def show
    topic = @api.info(@token)
    if topic
      render json: topic.dig(:rel, :topics) || {}
    else
      render :nothing, status: 500
    end
  end

  private

  def valid_topic?(topic)
    ['deeds'].include?(topic)
  end

  def find_token
    return unless params[:subscription] && params[:subscription][:token]
    @api = GoogleInstanceId.new(Rails.application.secrets.firebase_messaging_key)
    @token = params[:subscription][:token]
  end

  def require_token
    render_forbidden unless @api && @token
  end
end
