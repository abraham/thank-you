require 'test_helper'

class ThanksControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = create(:user)
    @deed = create(:deed, user: @user)
  end

  test 'POST /thanks' do
    assert_routing({ path: 'deeds/123/thanks', method: :post }, { controller: 'thanks', action: 'create', deed_id: '123' })
  end

  test 'GET /thanks/new' do
    assert_routing({ path: 'deeds/123/thanks/new', method: :get }, { controller: 'thanks', action: 'new', deed_id: '123'  })
  end

  test 'should redirect get new to sessions new' do
    get new_deed_thank_url(@deed)
    assert_redirected_to new_sessions_url
  end

  test 'should get new' do
    cookies[:user_id] = @user.id
    get new_deed_thank_url(@deed)
    assert_response :success
  end

  test 'should redirect post create to sessions new' do
    post deed_thanks_url(@deed)
    assert_redirected_to new_sessions_url
  end

  test 'should post create' do
    @twitter_status = Faker::Twitter.status
    stub_statuses_update
    cookies[:user_id] = @user.id

    assert_difference 'Thank.count', 1 do
      post deed_thanks_url @deed, params: { thank: { text: @twitter_status[:text], deed_id: @deed.id } }
    end

    assert_redirected_to deed_path(@deed)
    assert_equal 'Thank You was successfully created.', flash[:notice]
  end

  test 'should only allow creating one thank' do
    @twitter_status = Faker::Twitter.status
    thank = create(:thank, data: @twitter_status, user: @user)
    cookies[:user_id] = @user.id
    stub_statuses_update

    assert_difference 'Thank.count', 0 do
      post deed_thanks_url thank.deed, params: { thank: { text: @twitter_status[:text] } }
    end

    assert_redirected_to deed_path(thank.deed)
  end

  def stub_statuses_update
    stub_request(:post, 'https://api.twitter.com/1.1/statuses/update.json')
      .with(body: { in_reply_to_status_id: nil, status: "#{@twitter_status[:text]} #{deed_url(@deed)}" })
      .to_return(status: 200, body: @twitter_status.to_json)
  end
end
