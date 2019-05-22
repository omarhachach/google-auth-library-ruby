# Rails generator for configuring the google auth library for Rails. Performs
# the following actions
#
# - Creates a route for "/oauth2callback' in `config/routes.rb` for the 3LO
#   callback handler
# - Generates a migration for storing user credentials via ActiveRecord
# - Creates an initializer for further customization
#
class GoogleauthGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)
    class_option :generate_route,
                 type: :boolean,
                 default: true,
                 description: 'Don\'t insert routes in config/routes.rb'
    class_option :generate_migration,
                 type: :boolean,
                 default: true,
                 description: 'Don\'t generate a migration for token storage'
    class_option :generate_initializer,
                 type: :boolean,
                 default: true,
                 description: 'Don\t generate an initializer'
  
    def generate_config
      add_route unless options.skip_route
      add_migration unless options.skip_migration
      add_initializer unless options.skip_initializer
  
      say 'Please download your application credentials from ' \
          'http://console.developers.google.com ' \
          'and copy to config/client_secret.json.' unless client_secret_exists?
    end
  
    private
  
    def add_route
      route "match '/oauth2callback', "\
            'to: Google::Auth::WebUserAuthorizer::CallbackApp, '\
            'via: :all'
    end
  
    def add_migration
      generate 'migration', 'CreateGoogleAuthTokens user_id:string:index ' \
               'token:string'
    end
  
    def add_initializer
      copy_file 'googleauth.rb', 'config/initializers/googleauth.rb'
    end
  
    def client_secret_exists?
      path = File.join(Rails.root, 'config', 'client_secret.json')
      File.exist?(path)
    end
  end