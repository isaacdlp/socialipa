require 'test_helper'

class TwListItemsControllerTest < ActionController::TestCase
  setup do
    @tw_list_item = tw_list_items(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:tw_list_items)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create tw_list_item" do
    assert_difference('TwListItem.count') do
      post :create, tw_list_item: { item: @tw_list_item.item, tw_list_id: @tw_list_item.tw_list_id }
    end

    assert_redirected_to tw_list_item_path(assigns(:tw_list_item))
  end

  test "should show tw_list_item" do
    get :show, id: @tw_list_item
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @tw_list_item
    assert_response :success
  end

  test "should update tw_list_item" do
    patch :update, id: @tw_list_item, tw_list_item: { item: @tw_list_item.item, tw_list_id: @tw_list_item.tw_list_id }
    assert_redirected_to tw_list_item_path(assigns(:tw_list_item))
  end

  test "should destroy tw_list_item" do
    assert_difference('TwListItem.count', -1) do
      delete :destroy, id: @tw_list_item
    end

    assert_redirected_to tw_list_items_path
  end
end
