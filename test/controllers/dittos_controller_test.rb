require 'test_helper'

class DittosControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = create(:user)
    @deed = create(:deed, user: @user)
  end

  test 'POST /dittos' do
    assert_routing({ path: 'deeds/123/dittos', method: :post }, { controller: 'dittos', action: 'create', deed_id: '123' })
  end

  test 'GET /dittos/new' do
    assert_routing({ path: 'deeds/123/dittos/new', method: :get }, { controller: 'dittos', action: 'new', deed_id: '123'  })
  end

  test 'should redirect get new to sessions new' do
    get new_deed_ditto_url(@deed)
    assert_redirected_to new_sessions_url
  end

  test 'should get new' do
    cookies[:user_id] = @user.id
    get new_deed_ditto_url(@deed)
    assert_response :success
  end

  test 'should redirect post create to sessions new' do
    post deed_dittos_url(@deed)
    assert_redirected_to new_sessions_url
  end

  test 'should post create' do
    @twitter_status = Faker::Twitter.status
    stub_statuses_update
    cookies[:user_id] = @user.id

    assert_difference 'Ditto.count', 1 do
      post deed_dittos_url @deed, params: { ditto: { text: @twitter_status[:text], deed_id: @deed.id } }
    end

    assert_redirected_to deed_path(@deed)
    assert_equal 'Thank You was successfully created.', flash[:notice]
  end

  test 'should only allow creating one ditto' do
    @twitter_status = Faker::Twitter.status
    ditto = create(:ditto, data: @twitter_status, user: @user)
    cookies[:user_id] = @user.id
    stub_statuses_update

    assert_difference 'Ditto.count', 0 do
      post deed_dittos_url ditto.deed, params: { ditto: { text: @twitter_status[:text] } }
    end

    assert_redirected_to deed_path(ditto.deed)
  end

  def stub_statuses_update
    stub_request(:post, 'https://api.twitter.com/1.1/statuses/update.json')
      .with(body: { in_reply_to_status_id: nil, status: "#{@twitter_status[:text]} #{deed_url(@deed)}" })
      .to_return(status: 200, body: @twitter_status.to_json)
  end
end
