require 'test_helper'

class FlashTest < ActionDispatch::IntegrationTest
  test 'flash is present' do
    get new_deed_url
    assert_equal 'You must be signed in to do that.', flash[:warning]
    get root_url
    assert_select 'div.mdc-snackbar' do
      assert_select 'div.mdc-snackbar__text', 1
      assert_select 'div.mdc-snackbar__action-wrapper' do
        assert_select 'button[type=button].mdc-button.mdc-snackbar__action-button', 1
      end
    end
    assert_select 'div.snackbar-message[data-message="You must be signed in to do that."][data-type=warning][data-multiline=false]', 1
  end
end
