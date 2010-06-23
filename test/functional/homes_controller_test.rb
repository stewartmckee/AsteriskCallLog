require 'test_helper'

class HomesControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:homes)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_home
    assert_difference('Home.count') do
      post :create, :home => { }
    end

    assert_redirected_to home_path(assigns(:home))
  end

  def test_should_show_home
    get :show, :id => homes(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => homes(:one).id
    assert_response :success
  end

  def test_should_update_home
    put :update, :id => homes(:one).id, :home => { }
    assert_redirected_to home_path(assigns(:home))
  end

  def test_should_destroy_home
    assert_difference('Home.count', -1) do
      delete :destroy, :id => homes(:one).id
    end

    assert_redirected_to homes_path
  end
end
