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
    assert_equal 'You must be signed in to do that', flash[:warning]
  end

  test '#create should require user' do
    post deed_thanks_url(@deed)
    assert_redirected_to new_sessions_url
    assert_equal 'You must be signed in to do that', flash[:warning]
  end

  test '#new should render a form' do
    sign_in_as :user
    get new_deed_thank_url(@deed)
    assert_response :success
    assert_select "form[action=\"#{deed_thanks_path(@deed)}\"]#new_thank" do
      assert_select 'textarea#thank_text'
      assert_select 'div#deed_url', deed_url(@deed)
      assert_select 'div', "#{deed_url(@deed)} will be appended to the tweet"
      assert_select '#deed_url', deed_url(@deed)
      assert_select 'input[type=submit][value="Tweet"]'
      assert_select "a[href=\"#{deed_path(@deed)}\"]", 'Cancel'
      assert_select '#remaining_thank_text_length', 1
    end
  end

  test '#create requires a user' do
    post deed_thanks_url(@deed)
    assert_redirected_to new_sessions_url
  end

  test '#create should succeed' do
    sign_in_as :user
    tweet = Faker::Twitter.status
    stub = stub_statuses_update tweet, "#{tweet[:text]} #{deed_url(@deed)}"

    assert_difference '@deed.thanks.count', 1 do
      post deed_thanks_url(@deed), params: { thank: { text: tweet[:text] } }
    end

    thank = @deed.thanks.last
    assert_redirected_to deed_path(@deed)
    assert_equal tweet[:text], thank.text
    assert_equal 'Your Thank You has been tweeted.', flash[:notice]
    remove_request_stub stub
  end

  test '#new should only allow creating one thank' do
    user = sign_in_as :user
    create(:thank, text: "#{@deed.text} first", user: user, deed: @deed)
    get new_deed_thank_url(@deed)
    assert_redirected_to deed_path(@deed)
    assert_equal "You already thanked #{@deed.display_names}", flash[:error]
  end

  test '#create should only allow creating one thank' do
    user = sign_in_as :user
    tweet = Faker::Twitter.status
    create(:thank, text: "#{@deed.text} first", user: user, deed: @deed)
    stub = stub_statuses_update tweet, "#{tweet[:text]} #{deed_url(@deed)}"

    assert_no_difference 'Thank.count' do
      post deed_thanks_url(@deed), params: { thank: { text: "#{@deed.text} second" } }
    end

    assert_redirected_to deed_path(@deed)
    assert_equal "You already thanked #{@deed.display_names}", flash[:error]
    remove_request_stub stub
  end

  test '#create shows model errors' do
    sign_in_as :user

    assert_no_difference 'Thank.count' do
      post deed_thanks_url(@deed), params: { thank: { foo: 'bar' } }
    end
    assert_select '.card-error' do
      assert_select 'li', "Text can't be blank"
      assert_select 'li', "Twitter can't be blank"
      assert_select 'li', 2
    end
  end

  test '#create shows Twitter errors' do
    sign_in_as :user
    stub = stub_unauthorized

    assert_no_difference 'Thank.count' do
      post deed_thanks_url(@deed), params: { thank: { text: @deed.text } }
    end
    assert_select '.card-error' do
      assert_select 'li', 'Twitter error: Could not authenticate you'
      assert_select 'li', "Twitter can't be blank"
      assert_select 'li', 2
    end

    remove_request_stub stub
  end

  test '#create will not try to tweet invalid thanks' do
    sign_in_as :user

    assert_no_difference 'Thank.count' do
      post deed_thanks_url(@deed), params: { thank: { text: @deed.text * 10 } }
    end
    assert_select '.card-error' do
      assert_select 'li', "Twitter can't be blank"
      assert_select 'li', 'Twitter is not a valid tweet'
      assert_select 'li', 2
    end
  end
end
