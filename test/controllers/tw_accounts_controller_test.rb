require 'test_helper'

class TwAccountsControllerTest < ActionController::TestCase
  setup do
    @tw_account = tw_accounts(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:tw_accounts)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create tw_account" do
    assert_difference('TwAccount.count') do
      post :create, tw_account: { description: @tw_account.description, password: @tw_account.password, username: @tw_account.username }
    end

    assert_redirected_to tw_account_path(assigns(:tw_account))
  end

  test "should show tw_account" do
    get :show, id: @tw_account
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @tw_account
    assert_response :success
  end

  test "should update tw_account" do
    patch :update, id: @tw_account, tw_account: { description: @tw_account.description, password: @tw_account.password, username: @tw_account.username }
    assert_redirected_to tw_account_path(assigns(:tw_account))
  end

  test "should destroy tw_account" do
    assert_difference('TwAccount.count', -1) do
      delete :destroy, id: @tw_account
    end

    assert_redirected_to tw_accounts_path
  end
end
