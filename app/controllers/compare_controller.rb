require "json"
require "open-uri"
require "steam_scripts"

class CompareController < ApplicationController
  before_action :logged_in_user

  def index
    @user = session[:current_user]
    @friends = SteamScripts.friends_list(session[:current_user]['uid'])
  end

  def with_friend
    @user = session[:current_user]
    @friend_uid = params[:friend]
    @friend_name = SteamScripts.friend_summary_name(@friend_uid)
    @shared_games = SteamScripts.shared_games_names(SteamScripts.shared_games(SteamScripts.games_list(session[:current_user]['uid'], 1), SteamScripts.games_list(@friend_uid, 1)))
    if @shared_games.blank?
      @shared_games[0] = "No shared games!"
    end

    render :with_friend
  end

  def time_wasted
    @user = session[:current_user]
    if params.has_key?(:friend)
      @friend_uid = params[:friend]
      @name = SteamScripts.friend_summary_name(@friend_uid)
      @game_time = SteamScripts.games_list(@friend_uid, 2)
    else
      @name = session[:current_user]['nickname']
      @game_time = SteamScripts.games_list(session[:current_user]['uid'], 2)
    end

    render :time_wasted
  end

  def multi_compare
    if params[:friends].blank?
      flash[:error] = "Please select a friend!"
      return redirect_to compare_index_path
    else
      @user = session[:current_user]
      @friends_name = []
      friends_uid = []
      shared_games_ids = []
      params[:friends].each do |friend|
        friend_name = SteamScripts.friend_summary_name(friend)
        @friends_name << friend_name
        if shared_games_ids.blank?
          shared_games_ids = SteamScripts.shared_games(SteamScripts.games_list(session[:current_user]['uid'], 1), SteamScripts.games_list(friend, 1))
        else
          shared_games_ids = SteamScripts.shared_games(shared_games_ids, SteamScripts.games_list(friend, 1))
        end
      end

      @shared_games = []
      @shared_games = SteamScripts.shared_games_names(shared_games_ids)
      if @shared_games.blank?
        @shared_games[0] = "No shared games!"
      end
    end

    render :multi_compare
  end

  private

  def logged_in_user
    unless !session[:current_user].nil?
      redirect_to log_out_welcome_index_path
    end
  end

end
