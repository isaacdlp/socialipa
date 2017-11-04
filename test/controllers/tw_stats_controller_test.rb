require 'test_helper'

class TwStatsControllerTest < ActionController::TestCase
  setup do
    @tw_stat = tw_stats(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:tw_stats)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create tw_stat" do
    assert_difference('TwStat.count') do
      post :create, tw_stat: { concept: @tw_stat.concept, tw_account_id: @tw_stat.tw_account_id, value: @tw_stat.value }
    end

    assert_redirected_to tw_stat_path(assigns(:tw_stat))
  end

  test "should show tw_stat" do
    get :show, id: @tw_stat
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @tw_stat
    assert_response :success
  end

  test "should update tw_stat" do
    patch :update, id: @tw_stat, tw_stat: { concept: @tw_stat.concept, tw_account_id: @tw_stat.tw_account_id, value: @tw_stat.value }
    assert_redirected_to tw_stat_path(assigns(:tw_stat))
  end

  test "should destroy tw_stat" do
    assert_difference('TwStat.count', -1) do
      delete :destroy, id: @tw_stat
    end

    assert_redirected_to tw_stats_path
  end
end
