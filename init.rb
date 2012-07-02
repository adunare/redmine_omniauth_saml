require 'redmine'
require 'redmine_omniauth_cas'
require 'redmine_omniauth_cas/hooks'
require 'omniauth/patches'
require 'omniauth/dynamic_full_host'

# Patches to existing classes/modules
ActionDispatch::Callbacks.to_prepare do
  require_dependency 'redmine_omniauth_cas/account_helper_patch'
  require_dependency 'redmine_omniauth_cas/account_controller_patch'
end

# Plugin generic informations
Redmine::Plugin.register :redmine_omniauth_cas do
  name 'Redmine Omniauth plugin'
  description 'This plugin adds Omniauth support to Redmine'
  author 'Jean-Baptiste BARTH'
  author_url 'mailto:jeanbaptiste.barth@gmail.com'
  url 'http://github.com/jbbarth/redmine_omniauth_cas'
  version '0.1.1'
  requires_redmine :version_or_higher => '2.0.0'
  settings :default => { 'label_login_with_cas' => '', 'cas_server' => '' },
           :partial => 'settings/omniauth_cas_settings'
end

# OmniAuth CAS
setup_app = Proc.new do |env|
  addr = Redmine::OmniAuthCAS.cas_server
  cas_server = URI.parse(addr)
  if cas_server
    env['omniauth.strategy'].options.merge! :host => cas_server.host,
                                            :port => cas_server.port,
                                            :path => (cas_server.path != "/" ? cas_server.path : nil),
                                            :ssl  => cas_server.scheme == "https"
  end
end

# tell Rails we use this middleware, with some default value just in case
Rails.application.config.middleware.use OmniAuth::Builder do
  #url = "http://nadine.application.ac.centre-serveur.i2/"
  use OmniAuth::Strategies::CAS, :host => "localhost",
                                 :port => "9292",
                                 :ssl => false,
                                 :setup => setup_app
end
