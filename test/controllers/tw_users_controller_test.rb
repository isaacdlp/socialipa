require 'test_helper'

class TwUsersControllerTest < ActionController::TestCase
  setup do
    @tw_user = tw_users(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:tw_users)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create tw_user" do
    assert_difference('TwUser.count') do
      post :create, tw_user: { description: @tw_user.description, image_url: @tw_user.image_url, name: @tw_user.name, userid: @tw_user.userid, username: @tw_user.username }
    end

    assert_redirected_to tw_user_path(assigns(:tw_user))
  end

  test "should show tw_user" do
    get :show, id: @tw_user
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @tw_user
    assert_response :success
  end

  test "should update tw_user" do
    patch :update, id: @tw_user, tw_user: { description: @tw_user.description, image_url: @tw_user.image_url, name: @tw_user.name, userid: @tw_user.userid, username: @tw_user.username }
    assert_redirected_to tw_user_path(assigns(:tw_user))
  end

  test "should destroy tw_user" do
    assert_difference('TwUser.count', -1) do
      delete :destroy, id: @tw_user
    end

    assert_redirected_to tw_users_path
  end
end
