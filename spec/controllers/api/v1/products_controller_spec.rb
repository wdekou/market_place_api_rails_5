describe Api::V1::ProductsController do
  describe "GET #show" do
    before(:each) do
      @product = FactoryGirl.create :product
      get :show, params: { id: @product.id }
    end

    it "has the user as a embeded object" do
      product_owner = json_response[:included][0]
      expect(product_owner[:attributes][:email]).to eql @product.user.email
    end

    it "returns the information about a reporter on a hash" do
      product_response = json_response[:data][:attributes]
      expect(product_response[:title]).to eql @product.title
    end

    it { should respond_with 200 }
  end

  describe "GET #index" do
    before(:each) do
      4.times {FactoryGirl.create :product }
    end

    context 'when is not receiving any product_ids paramater' do
      before(:each) do
        get :index
      end

      it "returns 4 records from the database" do
        products_response = json_response[:data]
        expect(products_response).to have(4).items
      end

      it "returns the user object into each product" do
        products_response = json_response[:data]
        products_response.each do |product_response|
          expect(product_response[:relationships][:user]).to be_present
        end
      end

      it { should respond_with 200 }
    end


    context 'when product_ids paramater is sent' do
      before(:each) do
        @user = FactoryGirl.create :user
        3.times { FactoryGirl.create :product, user: @user }
        get :index, params: { "product-ids": @user.product_ids }
      end

      it 'returns just the products that belong to the user' do
        products_response = json_response[:data]
        products_owner = json_response[:included][0]
        puts products_owner.inspect
        products_response.each do |product_response|
          expect(products_owner[:attributes][:email]).to eql @user.email
        end
      end
    end


  end

  describe "POST #create" do
    context 'when is successfully created' do
      before(:each) do
        user = FactoryGirl.create :user
        @product_attributes = FactoryGirl.attributes_for :product
        api_authorization_header user.auth_token
        post :create, params: { user_id: user.id, product: @product_attributes}
      end

      it "renders the json representation for the product record just created" do
        product_response = json_response[:data][:attributes]
        expect(product_response[:title]).to eql @product_attributes[:title]
      end

      it { should respond_with 201 }
    end

    context "when is not created" do
      before(:each) do
        user = FactoryGirl.create :user
        @invalid_product_attributes = { title: "Smart TV", price: "Twelve dollars" }
        api_authorization_header user.auth_token
        post :create, params: {user_id: user.id, product: @invalid_product_attributes }
      end

      it "renders an errors json" do
        product_response = json_response
        expect(product_response).to have_key(:errors)
      end

      it 'renders the json errors whye the user could not be created' do
        product_response = json_response
        expect(product_response[:errors][:price]).to include 'is not a number'
      end

      it { should respond_with 422 }
    end
  end

  describe 'PUT/PATCH #update' do
    before(:each) do
      @user = FactoryGirl.create :user
      @product = FactoryGirl.create :product, user: @user
      api_authorization_header @user.auth_token
    end

    context 'when is successfully updated' do
      before(:each) do
        patch :update, params: { user_id: @user.id, id: @product.id,
                         product: { title: "An expensive TV" } }
      end

      it "renders the json representation for the updated user" do
        product_response = json_response[:data][:attributes]
        expect(product_response[:title]).to eql "An expensive TV"
      end

      it { should respond_with 200 }
    end

    context "when is not updated" do
      before(:each) do
        patch :update, params: { user_id: @user.id, id: @product.id,
                         product: { price: "two hundred" } }
      end

      it "renders an errors json" do
        product_response = json_response
        expect(product_response).to have_key(:errors)
      end

      it "renders the json errors on whye the user could not be created" do
        product_response = json_response
        expect(product_response[:errors][:price]).to include "is not a number"
      end

      it { should respond_with 422 }
    end

    describe 'DELETE #destroy' do
      before(:each) do
        @user = FactoryGirl.create :user
        @product = FactoryGirl.create :product, user: @user
        api_authorization_header @user.auth_token
        delete :destroy, params: { user_id: @user.id, id: @product.id }
      end

      it { should respond_with 204 }
    end
  end
end
