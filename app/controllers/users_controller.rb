class UsersController < ApplicationController
  before_action :require_signin
  before_action :require_editor

  def drafts
    @deeds = current_user.deeds.newest.draft.includes(thanks: :user).limit(25)
    @thanked_deed_ids = Thank.where(deed: @deeds).where(user: current_user).pluck(:deed_id)
  end
end
