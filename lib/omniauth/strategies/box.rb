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
puts "****** IN REQUEST"
        options[:response_type] ||= 'code'
puts "request_phase >>>>>> #{options}"
        super
      end
      
      def callback_phase
puts "****** IN CALLBACK"
p request.params
        request.params['state'] = session['omniauth.state']
        options[:grant_type] ||= 'authorization_code'
        options[:code] ||= session['omniauth.state']
p request.params
        super
      end
        
      def build_access_token
puts "****** IN BUILD ACCESS_TOKEN"

        access_token = super
puts "CLIENT: >>>>>>>>>>>>>>>> #{client.inspect}"
puts "ACCESS TOKEN: >>>>>>>>>>>>>>>> #{access_token.inspect}"
puts "ACCESS_TOKEN.TOKEN >>>>>>>>>>>>>>>> #{access_token.token.inspect}"
        token = access_token.token
puts "TOKEN >>>>>>>>>>>>>>>>> #{client.inspect}"
puts "TOKEN >>>>>>>>>>>>>>>>> #{token.inspect}"
puts "ACCESS_TOKEN.params >>>>>>>>>>>>>>>>> #{access_token.params.inspect}"

# here, merge grant type and request.params[:code] / response code
        @access_token = ::OAuth2::AccessToken.new(client, token, access_token.params)
puts ">>>>>>>>>>>>>>>>>>>>>>> #{@access_token.inspect}"
        super
      end
 
#      def auth_hash
#puts "****** IN AUTH_HASH"
#        thing = OmniAuth::Utils.deep_merge(super, client_params.merge({
#          :grant_type => 'authorization_code'}))
#        thing
#      end

      def raw_info
      #  @raw_info ||= access_token.get('/api/v1/users/current.json').parsed
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
        raw_info['login']#['email_addresses'].detect{|address| address['type'] == 'primary'}['address']
      end
    end
  end
end
