class DeedsController < ApplicationController
  before_action :find_deed, only: [:show, :edit, :update, :publish]
  before_action :require_signin, except: [:index, :popular, :show]
  before_action :require_admin, only: [:drafts]
  before_action :require_edit_access, only: [:edit, :update, :publish]
  before_action :require_editor, only: [:start, :etl, :new, :create]
  before_action :find_example_deeds, only: [:start, :etl, :edit, :create]

  PAGE_COUNT = 10

  def create
    @deed = current_user.deeds.create(deeds_params)

    if @deed.valid?
      redirect_to @deed, flash: { notice: 'Deed created' }
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
    redirect_to @deed, flash: { notice: "Published Deeds can't be edited." } unless @deed.draft?
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
      redirect_to edit_deed_path(@deed), flash: { notice: 'Deed created' }
    else
      render :start
    end
  end

  def new
    @deed = Deed.new
  end

  def update
    if @deed.update(deeds_params) && @deed.valid? && @deed.save
      redirect_to @deed, flash: { notice: 'Deed updated' }
    else
      render :edit
    end
  end

  def publish
    if @deed.published!
      fcm = FCM.new(Rails.application.secrets.firebase_messaging_key)
      notification = {
        title: "@#{current_user.screen_name} added a new Deed on Thank You",
        body: @deed.display_text,
        icon: current_user.avatar_url,
        click_action: deed_url(@deed)
      }
      fcm.send_to_topic('deeds', notification: notification)
      redirect_to @deed, flash: { notice: 'Published' }
    else
      render :edit
    end
  end

  private

  def find_example_deeds
    @examples_deeds = [{
      text: 'Local community impact',
      deed: Deed.find_by_id('fe5b2ec6-1ad2-4bef-b8ab-506505501c46')
    }, {
      text: 'Standing up to authority',
      deed: Deed.find_by_id('12b168b4-a994-4a0a-884a-5c5711e0b18f')
    }, {
      text: 'Supporting underrepresented groups',
      deed: Deed.find_by_id('996b8041-e52f-49cc-8ea0-3aee5ad00bbe')
    }]
  end

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

    redirect_to deed_path(@deed), flash: { warning: 'You do not have permission to do that.' }
  end
end
