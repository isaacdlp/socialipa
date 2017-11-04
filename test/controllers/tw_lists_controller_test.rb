require 'test_helper'

class TwListsControllerTest < ActionController::TestCase
  setup do
    @tw_list = tw_lists(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:tw_lists)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create tw_list" do
    assert_difference('TwList.count') do
      post :create, tw_list: { description: @tw_list.description, name: @tw_list.name }
    end

    assert_redirected_to tw_list_path(assigns(:tw_list))
  end

  test "should show tw_list" do
    get :show, id: @tw_list
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @tw_list
    assert_response :success
  end

  test "should update tw_list" do
    patch :update, id: @tw_list, tw_list: { description: @tw_list.description, name: @tw_list.name }
    assert_redirected_to tw_list_path(assigns(:tw_list))
  end

  test "should destroy tw_list" do
    assert_difference('TwList.count', -1) do
      delete :destroy, id: @tw_list
    end

    assert_redirected_to tw_lists_path
  end
end
