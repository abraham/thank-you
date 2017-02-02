require 'test_helper'

class DittosControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = create(:user)
    @thank = create(:thank, user: @user)
  end

  test 'should get new' do
    get dittos_new_url(@thank)
    assert_response :success
  end

  test 'should post create' do
    @twitter_status = Faker::Twitter.status
    stub_statuses_update
    cookies[:user_id] = @user.id

    assert_difference 'Ditto.count', 1 do
      post dittos_create_url @thank, params: { ditto: { text: @twitter_status[:text] } }
    end

    assert_redirected_to thanks_show_path(@thank)
    assert_equal 'Thank you was successfully created.', flash[:notice]
  end

  def stub_statuses_update
    stub_request(:post, 'https://api.twitter.com/1.1/statuses/update.json')
      .with(body: { in_reply_to_status_id: nil, status: @twitter_status[:text] })
      .to_return(status: 200, body: @twitter_status.to_json)
  end
end
