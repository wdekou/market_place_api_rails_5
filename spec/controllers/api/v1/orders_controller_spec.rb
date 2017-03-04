describe Api::V1::OrdersController do

  describe "GET #index" do
    before(:each) do
      current_user = FactoryGirl.create :user
      api_authorization_header current_user.auth_token
      4.times { FactoryGirl.create :order, user: current_user }
      get :index, params: { user_id: current_user.id }
    end

    it "returns 4 order records from the user" do
      puts json_response.inspect
      orders_response = json_response[:data]
      expect(orders_response).to have(4).items
    end

    it { should respond_with 200 }
  end

end