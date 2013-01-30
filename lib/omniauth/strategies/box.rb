require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class Box < OmniAuth::Strategies::OAuth2
      
      option :name, 'box'
      
      option :client_options, {
        :site => 'https://api.box.com',
        :authorize_url => '/oauth2/authorize',
        :token_url => '/oauth2/token'
      }
      
      uid { raw_info['id'] }
      
      info do
        prune!({
          :nickname => raw_info['name'],
          :name => raw_info['full_name'],
          :location => raw_info['location'],
          :image => raw_info['mugshot_url'],
          :description => raw_info['job_title'],
          :email => primary_email,
          :urls => {
            :box => raw_info['web_url']
          }
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
#        options[:grant_type] ||= 'authorization_code'
#        options[:code] ||= session['omniauth.code']
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
