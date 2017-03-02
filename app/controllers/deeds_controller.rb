class DeedsController < ApplicationController
  before_action :find_deed, only: [:show, :edit, :update, :publish]
  before_action :require_signin, except: [:index, :popular, :show]
  before_action :require_admin, only: [:drafts]
  before_action :require_edit_access, only: [:edit, :update, :publish]
  before_action :require_editor, only: [:start, :etl, :new, :create]

  PAGE_COUNT = 10

  def create
    @deed = current_user.deeds.create(deeds_params)

    if @deed.valid?
      redirect_to @deed, flash: { notice: 'Deed created successfully.' }
    else
      render :new
    end
  end

  def index
    @next = true if params[:before] && !params[:after]
    @before = Time.parse(params[:before]) if params[:before]
    @after = Time.parse(params[:after]) if params[:after]

    @deeds = Deed.newest.published.where(Deed.arel_table[:created_at].lt(@before || Time.now.utc))
                 .limit(PAGE_COUNT)
                 .includes(thanks: :user)
    @thanked_deed_ids = Thank.where(deed: @deeds).where(user: current_user).pluck(:deed_id)

    @next_before = @after
    @prev_before = @deeds.last.created_at if @deeds.size >= PAGE_COUNT
    @prev_after = @before
  end

  def popular
    @deeds = Deed.published.order(thanks_count: :desc).includes(thanks: :user).limit(PAGE_COUNT)
    @thanked_deed_ids = Thank.where(deed: @deeds).where(user: current_user).pluck(:deed_id)
  end

  def drafts
    @deeds = Deed.newest.draft.includes(thanks: :user).limit(PAGE_COUNT)
    @thanked_deed_ids = Thank.where(deed: @deeds).where(user: current_user).pluck(:deed_id)
  end

  def show
    render_not_found unless @deed.published? || user_can_modify_deed?
    @thanked = current_user && current_user.thanked?(@deed)
  end

  def edit
    redirect_to @deed, flash: { notice: "You can't edit published deeds" } unless @deed.draft?
    @thanked = current_user && current_user.thanked?(@deed)
  end

  def start
    @deed = Deed.new
  end

  def etl
    @deed = current_user.deeds.build(deeds_params)
    @deed.etl

    if @deed.tweet?
      @deed.text = @deed.tweet.text
      @deed.names = [@deed.tweet.user.screen_name]
    end

    if @deed.tweet? && @deed.save
      redirect_to edit_deed_path(@deed), flash: { notice: 'Deed created successfully.' }
    else
      render :start
    end
  end

  def new
    @deed = Deed.new
  end

  def update
    if @deed.update(deeds_params) && @deed.valid? && @deed.save
      redirect_to @deed, flash: { notice: 'Deed updated successfully.' }
    else
      render :edit
    end
  end

  def publish
    if @deed.published!
      redirect_to @deed, flash: { notice: 'Deed published.' }
    else
      render :edit
    end
  end

  private

  def find_deed
    @deed = Deed.includes(:links, thanks: :user).find(params[:id] || params[:deed_id])
  end

  def user_can_modify_deed?
    current_user && current_user.edit?(@deed)
  end

  def deeds_params
    params.require(:deed).permit(:twitter_id, :text, names: [])
  end

  def require_edit_access
    return if user_can_modify_deed?

    redirect_to deed_path(@deed), flash: { warning: 'You do not have permission to do that' }
  end
end
