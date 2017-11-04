require 'test_helper'

class TwStudiesControllerTest < ActionController::TestCase
  setup do
    @tw_study = tw_studies(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:tw_studies)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create tw_study" do
    assert_difference('TwStudy.count') do
      post :create, tw_study: { name: @tw_study.name }
    end

    assert_redirected_to tw_study_path(assigns(:tw_study))
  end

  test "should show tw_study" do
    get :show, id: @tw_study
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @tw_study
    assert_response :success
  end

  test "should update tw_study" do
    patch :update, id: @tw_study, tw_study: { name: @tw_study.name }
    assert_redirected_to tw_study_path(assigns(:tw_study))
  end

  test "should destroy tw_study" do
    assert_difference('TwStudy.count', -1) do
      delete :destroy, id: @tw_study
    end

    assert_redirected_to tw_studies_path
  end
end
