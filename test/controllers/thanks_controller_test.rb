require 'test_helper'

class ThanksControllerTest < ActionDispatch::IntegrationTest
  def setup
    @deed = create(:deed)
  end

  test 'POST /thanks' do
    assert_routing({ path: 'deeds/123/thanks', method: :post }, controller: 'thanks', action: 'create', deed_id: '123')
  end

  test 'GET /thanks/new' do
    assert_routing({ path: 'deeds/123/thanks/new', method: :get }, controller: 'thanks', action: 'new', deed_id: '123')
  end

  test '#new should require user' do
    get new_deed_thank_url(@deed)
    assert_redirected_to new_sessions_url
  end

  test '#new should render a form' do
    sign_in_as :user
    get new_deed_thank_url(@deed)
    assert_response :success
    assert_select "form[action=\"#{deed_thanks_path(@deed)}\"]#new_thank" do
      assert_select 'textarea#thank_text'
      assert_select 'span', "#{deed_url(@deed)} will be appended to the tweet"
      assert_select 'input[type=submit][value="Tweet"]'
      assert_select "a[href=\"#{deed_path(@deed)}\"]", 'Cancel'
    end
  end

  test 'should redirect post create to sessions new' do
    post deed_thanks_url(@deed)
    assert_redirected_to new_sessions_url
  end

  test 'should post create' do
    sign_in_as :user
    @twitter_status = Faker::Twitter.status
    stub_statuses_update

    assert_difference 'Thank.count', 1 do
      post deed_thanks_url @deed, params: { thank: { text: @twitter_status[:text], deed_id: @deed.id } }
    end

    assert_redirected_to deed_path(@deed)
    assert_equal 'Thank You was successfully created.', flash[:notice]
  end

  test 'should only allow creating one thank' do
    user = sign_in_as :user
    @twitter_status = Faker::Twitter.status
    thank = create(:thank, data: "#{@deed.text} first", user: user)
    stub_statuses_update

    assert_difference 'Thank.count', 0 do
      post deed_thanks_url thank.deed, params: { thank: { text: "#{@deed.text} second" } }
    end

    assert_redirected_to deed_path(thank.deed)
  end

  def stub_statuses_update
    stub_request(:post, 'https://api.twitter.com/1.1/statuses/update.json')
      .with(body: { in_reply_to_status_id: nil, status: "#{@twitter_status[:text]} #{deed_url(@deed)}" })
      .to_return(status: 200, body: @twitter_status.to_json)
  end
end
