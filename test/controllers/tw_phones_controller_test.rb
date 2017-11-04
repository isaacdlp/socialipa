require 'test_helper'

class TwPhonesControllerTest < ActionController::TestCase
  setup do
    @tw_phone = tw_phones(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:tw_phones)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create tw_phone" do
    assert_difference('TwPhone.count') do
      post :create, tw_phone: { code: @tw_phone.code, name: @tw_phone.name, number: @tw_phone.number }
    end

    assert_redirected_to tw_phone_path(assigns(:tw_phone))
  end

  test "should show tw_phone" do
    get :show, id: @tw_phone
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @tw_phone
    assert_response :success
  end

  test "should update tw_phone" do
    patch :update, id: @tw_phone, tw_phone: { code: @tw_phone.code, name: @tw_phone.name, number: @tw_phone.number }
    assert_redirected_to tw_phone_path(assigns(:tw_phone))
  end

  test "should destroy tw_phone" do
    assert_difference('TwPhone.count', -1) do
      delete :destroy, id: @tw_phone
    end

    assert_redirected_to tw_phones_path
  end
end
