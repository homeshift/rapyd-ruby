require 'test_helper'

module Rapyd
	class ApiRequestTest < ActiveSupport::TestCase

		# runs before each test
		def setup
			Rapyd.mode = "test"
		end

	  # runs after each test
	  def teardown
	    Rapyd.remove_instance_variable :@api_base if Rapyd.instance_variable_defined? :@api_base
	  end

	  test ".api_url" do
	    assert_equal "https://sandboxapi.rapyd.net", Rapyd::ApiRequest.api_url
	  end

	  test ".api_url specifies URL correctly" do
	    api_url = Rapyd::ApiRequest.api_url("/v1/test")
	    assert_equal "https://sandboxapi.rapyd.net/v1/test", api_url
	  end

	  test "live mode" do
	    Rapyd.mode = "live"
	    assert_equal "https://api.rapyd.net", Rapyd::ApiRequest.api_url
	  end

	  # test "offline request fails with Rapyd::ApiConnectionError" do
	  # 	VCR.use_cassette("api_connection") do
		 #  	assert_raises(Rapyd::ApiConnectionError) do
		 #  		Rapyd::Payment.list
		 #  	end
		 #  end
	  # end

	  test "unauthorised request fails with Rapyd::AuthenticationError" do
	  	VCR.use_cassette("unauthenticated") do
		  	assert_raises(Rapyd::AuthenticationError) do
		  		Rapyd::Payment.list
		  	end
		  end
	  end

	  test "GET request does not raise" do
	  	VCR.use_cassette("get") do
	  		assert_nothing_raised do
	  			Rapyd::Payment.list
	  		end
		  end
	  end

	  test "POST request does not raise" do
	  	params = {
		    "addresses": [],
		    "business_vat_id": "123456789",
		    "coupon": "",
		    "description": "",
		    "email": "johndoe9993@rapyd.net",
		    "ewallet": "",
		    "invoice_prefix": "JD-",
		    "metadata": {
		    	"merchant_defined": true
		    },
		    "name": "John Doe",
		    "payment_method": nil,
		    "phone_number": "+14155559993"
			}
	  	VCR.use_cassette("post") do
	  		assert_nothing_raised do
	  			Rapyd::Customer.create(params)
	  		end
		  end
	  end

	  test "invalid JSON response fails with Rapyd::ParseError" do
	  	VCR.use_cassette("invalid_response") do
		  	assert_raises(Rapyd::ParseError) do
		  		Rapyd::Payment.list
		  	end
		  end
	  end

	end
end