require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class Box < OmniAuth::Strategies::OAuth2
      
      option :name, 'box'
      
      option :client_options, {
        :site => 'https://api.box.com',
        :authorize_url => 'https://api.box.com/oauth2/authorize',
        :token_url     => 'https://api.box.com/oauth2/token'
      }
      
      uid { raw_info['id'] }
      
      info do
        prune!({
          :type => raw_info['type'],
          :name => raw_info['name'],
          :login => primary_email,
          :created_at => raw_info['created_at'],
          :modified_at => raw_info['modified_at'],
          :language => raw_info['language'],
          :space_amount => raw_info['space_amount'],
          :max_upload_size => raw_info['max_upload_size'],
          :status => raw_info['status'],
          :job_title => raw_info['job_title'],
          :phone => raw_info['phone'],
          :address => raw_info['address'],
          :avatar_url => raw_info['avatar_url'],
        })
      end

      extra do
        prune!({:raw_info => raw_info})
      end
      

      def request_phase
        options[:response_type] ||= 'code'
        super
      end
      

      def callback_phase
        request.params['state'] = session['omniauth.state']
        super
      end
        

      def build_access_token
        access_token = super
        token = access_token.token
        @access_token = ::OAuth2::AccessToken.new(client, token, access_token.params)
        super
      end
 

      def raw_info
        @raw_info ||= access_token.get('/2.0/users/me').parsed
      end
      

      private

      def prune!(hash)
        hash.delete_if do |_, value|
          prune!(value) if value.is_a?(Hash)
          value.nil? || (value.respond_to?(:empty?) && value.empty?)
        end
      end
      
      def primary_email
        raw_info['login']
      end
    end
  end
end
