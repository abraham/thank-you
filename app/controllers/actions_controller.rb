class ActionsController < ApplicationController
  def create
    @action = Action.create(action_params)

    redirect_to @action
  end

  def index; end

  def new; end

  private

  def action_params
    params.require(:action).permit(:status_id, :text)
  end
end
