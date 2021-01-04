class WelcomeController < ApplicationController
  # auth callback POST comes from Steam so we can't attach CSRF token
  skip_before_action :verify_authenticity_token, :only => :auth_callback

  def index
    session.clear
    reset_session
  end

  def auth_callback
    auth = request.env['omniauth.auth']
    session[:current_user] = { :nickname => auth.info['nickname'],
                                          :image => auth.info['image'],
                                          :uid => auth.uid }

    redirect_to compare_index_url
  end

  def log_out
    session.clear
    reset_session
    redirect_to root_url
  end
end
