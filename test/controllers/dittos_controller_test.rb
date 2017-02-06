require 'test_helper'

class DittosControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = create(:user)
    @thank = create(:thank, user: @user)
  end

  test 'POST /dittos' do
    assert_routing({ path: 'thanks/123/dittos', method: :post }, { controller: 'dittos', action: 'create', thank_id: '123' })
  end

  test 'GET /dittos/new' do
    assert_routing({ path: 'thanks/123/dittos/new', method: :get }, { controller: 'dittos', action: 'new', thank_id: '123'  })
  end

  test 'should redirect get new to sessions new' do
    get new_thank_ditto_url(@thank)
    assert_redirected_to new_session_url
  end

  test 'should get new' do
    cookies[:user_id] = @user.id
    get new_thank_ditto_url(@thank)
    assert_response :success
  end

  test 'should redirect post create to sessions new' do
    post thank_dittos_url(@thank)
    assert_redirected_to new_session_url
  end

  test 'should post create' do
    @twitter_status = Faker::Twitter.status
    stub_statuses_update
    cookies[:user_id] = @user.id

    assert_difference 'Ditto.count', 1 do
      post thank_dittos_url @thank, params: { ditto: { text: @twitter_status[:text], thank_id: @thank.id } }
    end

    assert_redirected_to thank_path(@thank)
    assert_equal 'Thank you was successfully created.', flash[:notice]
  end

  test 'should only allow creating one ditto' do
    @twitter_status = Faker::Twitter.status
    ditto = create(:ditto, data: @twitter_status, user: @user)
    cookies[:user_id] = @user.id
    stub_statuses_update

    assert_difference 'Ditto.count', 0 do
      post thank_dittos_url ditto.thank, params: { ditto: { text: @twitter_status[:text] } }
    end

    assert_redirected_to thank_path(ditto.thank)
  end

  def stub_statuses_update
    stub_request(:post, 'https://api.twitter.com/1.1/statuses/update.json')
      .with(body: { in_reply_to_status_id: nil, status: "#{@twitter_status[:text]} #{thank_url(@thank)}" })
      .to_return(status: 200, body: @twitter_status.to_json)
  end
end
