require 'test_helper'

class TwProxiesControllerTest < ActionController::TestCase
  setup do
    @tw_proxy = tw_proxies(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:tw_proxies)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create tw_proxy" do
    assert_difference('TwProxy.count') do
      post :create, tw_proxy: { host: @tw_proxy.host, password: @tw_proxy.password, port: @tw_proxy.port, username: @tw_proxy.username }
    end

    assert_redirected_to tw_proxy_path(assigns(:tw_proxy))
  end

  test "should show tw_proxy" do
    get :show, id: @tw_proxy
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @tw_proxy
    assert_response :success
  end

  test "should update tw_proxy" do
    patch :update, id: @tw_proxy, tw_proxy: { host: @tw_proxy.host, password: @tw_proxy.password, port: @tw_proxy.port, username: @tw_proxy.username }
    assert_redirected_to tw_proxy_path(assigns(:tw_proxy))
  end

  test "should destroy tw_proxy" do
    assert_difference('TwProxy.count', -1) do
      delete :destroy, id: @tw_proxy
    end

    assert_redirected_to tw_proxies_path
  end
end
