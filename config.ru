#!/usr/bin/env ruby
# vim: sts=2 et ai
require 'rubygems'
require 'gollum/frontend/app'
require 'omniauth'
require 'omniauth-github'

use Rack::Session::Cookie
use OmniAuth::Builder do
  # Need to use scope 'user' to get access to email information.
  # TODO: This should be fixed in some way.
  provider :github, ENV['GITHUB_KEY'], ENV['GITHUB_SECRET'], scope: 'user'
end

class GitHubPullRequest
  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)

    if request.path =~ /^\/pull/
      status = system({'GIT_DIR' => "#{ENV['WIKI_REPO']}/.git"}, 'git pull')
      if status
        return [200, {}, ['ok']]
      else
        return [401, {}, ['not-ok']]
      end
    end
    
    if request.path =~ /^\/push/
      status = system({'GIT_DIR' => "#{ENV['WIKI_REPO']}/.git"}, 'git push')
      if status
        return [200, {}, ['ok']]
      else
        return [401, {}, ['not-ok']]
      end
    end
    @app.call(env)
  end
end

use GitHubPullRequest

class OmniAuthSetGollumAuthor

  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)
    session = env['rack.session']

    # Check whether we are authorized, if not redirect.
    if request.path =~ /^\/(edit|create|revert|delete)\// \
        and not session['gollum.author']
      session[:return_to] = request.fullpath
      # Redirect to authentication
      return [302, {'Location' => '/auth/github'}, []]
    end

    # Setting authentication information and redirect to previously intended location
    if request.path =~ /^\/auth\/[^\/]+\/callback/ and env['omniauth.auth']
      # puts env['omniauth.auth'].to_s
      # Creating the 'gollum.author' session object which indicates that
      # the request is authenticated.
      # TODO: This should be extended to ensure the user is a member of
      # a specific Github organization.
      session['gollum.author'] = {
        :name => env['omniauth.auth'][:info][:name],
        :email => env['omniauth.auth'][:info][:email]
      }
      return_to = session[:return_to]
      puts 'Return to' + return_to
      session.delete(:return_to)
      return [302, {'Location' => return_to}, []]
    end
    @app.call(env)
  end
end

use OmniAuthSetGollumAuthor
  
gollum_path = File.expand_path(ENV['WIKI_REPO']) # CHANGE THIS TO POINT TO YOUR OWN WIKI REPO
Precious::App.set(:gollum_path, gollum_path)
Precious::App.set(:default_markup, :markdown) # set your favorite markup language
Precious::App.set(:wiki_options, {:mathjax => true, :live_preview => false, :universal_toc => false, :css => true})
run Precious::App
