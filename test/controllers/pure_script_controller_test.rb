require "test_helper"

class PureScriptControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get pure_script_show_url
    assert_response :success
  end
end
