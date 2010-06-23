require 'test_helper'

class CdrEntriesControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:cdr_entries)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_cdr_entries
    assert_difference('CdrEntries.count') do
      post :create, :cdr_entries => { }
    end

    assert_redirected_to cdr_entries_path(assigns(:cdr_entries))
  end

  def test_should_show_cdr_entries
    get :show, :id => cdr_entries(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => cdr_entries(:one).id
    assert_response :success
  end

  def test_should_update_cdr_entries
    put :update, :id => cdr_entries(:one).id, :cdr_entries => { }
    assert_redirected_to cdr_entries_path(assigns(:cdr_entries))
  end

  def test_should_destroy_cdr_entries
    assert_difference('CdrEntries.count', -1) do
      delete :destroy, :id => cdr_entries(:one).id
    end

    assert_redirected_to cdr_entries_path
  end
end
