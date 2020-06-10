module Rapyd
  class ApiResource
    include Rapyd::RapydObject

    API_VERSION = 'v1'.freeze

    def self.class_name
      self.name.split('::')[-1]
    end

    def self.path
      if self == ApiResource
        raise NotImplementedError.new('ApiResource is an abstract class. Define on its subclasses (Payment, Transfer, etc.)')
      end
      "#{CGI.escape(class_name.downcase)}s"
    end

    def self.resource_url(resource_id)
      "#{collection_url}/#{resource_id}"
    end

    def self.collection_url(resource_id = nil)
      if self == ApiResource
        raise NotImplementedError.new("ApiResource is an abstract class. You should perform actions on its subclasses (Payment, Transfer, etc.)")
      end
      "/#{API_VERSION}/#{path}"
    end

    def self.list(params = {}, headers = {})
      response = Rapyd::ApiRequest.request(:get, collection_url, params, headers)
      convert_to_rapyd_object(response)
    end

    def self.create(params = {}, headers = {})
      response = Rapyd::ApiRequest.request(:post, collection_url, params, headers)
      convert_to_rapyd_object(response)
    end

    def self.retrieve(id)
      raise NotImplementedError.new("ApiResource is an abstract class. Define on a subclass where needed.")
    end

    def self.enable(id)
      raise NotImplementedError.new("ApiResource is an abstract class. Define on a subclass where needed.")
    end

    def self.disable(id)
      raise NotImplementedError.new("ApiResource is an abstract class. Define on a subclass where needed.")
    end

    def self.update(id)
      raise NotImplementedError.new("ApiResource is an abstract class. Define on a subclass where needed.")
    end

    def self.delete(id)
      raise NotImplementedError.new("ApiResource is an abstract class. Define on a subclass where needed.")
    end

    def self.complete(id)
      raise NotImplementedError.new("ApiResource is an abstract class. Define on a subclass where needed.")
    end

    def self.cancel(id)
      raise NotImplementedError.new("ApiResource is an abstract class. Define on a subclass where needed.")
    end

    # def self.create(params = {}, opts = {})
    #   response = Transferwise::Request.request(:post, collection_url, params, opts)
    #   convert_to_transferwise_object(response)
    # end

    # def self.list(filters = {}, headers = {}, resource_id = nil)
    #   response = Transferwise::Request.request(:get, collection_url(resource_id), filters, headers)
    #   convert_to_transferwise_object(response)
    # end

    # def self.get(resource_id, headers = {})
    #   response = Transferwise::Request.request(:get, resource_url(resource_id), {}, headers)
    #   convert_to_transferwise_object(response)
    # end
  end
end