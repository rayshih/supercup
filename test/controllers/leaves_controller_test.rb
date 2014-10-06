require 'test_helper'

class LeavesControllerTest < ActionController::TestCase
  setup do
    @leafe = leaves(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:leaves)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create leafe" do
    assert_difference('Leafe.count') do
      post :create, leafe: { end_date: @leafe.end_date, hours: @leafe.hours, start_date: @leafe.start_date, worker_id: @leafe.worker_id }
    end

    assert_redirected_to leafe_path(assigns(:leafe))
  end

  test "should show leafe" do
    get :show, id: @leafe
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @leafe
    assert_response :success
  end

  test "should update leafe" do
    patch :update, id: @leafe, leafe: { end_date: @leafe.end_date, hours: @leafe.hours, start_date: @leafe.start_date, worker_id: @leafe.worker_id }
    assert_redirected_to leafe_path(assigns(:leafe))
  end

  test "should destroy leafe" do
    assert_difference('Leafe.count', -1) do
      delete :destroy, id: @leafe
    end

    assert_redirected_to leaves_path
  end
end
