require "json"
require "open-uri"
require "steam_scripts"

class CompareController < ApplicationController

  def index
    @user = session[:current_user]
    @friends = SteamScripts.friends_list(session[:current_user]['uid'])
    render :index
  end

  def with_friend
    @user = session[:current_user]
    @friend_uid = params[:friend]
    @friend_name = SteamScripts.friend_summary_name(@friend_uid)
    @shared_games = SteamScripts.shared_games_names(SteamScripts.shared_games(SteamScripts.games_list(session[:current_user]['uid']), SteamScripts.games_list(@friend_uid)))
    if @shared_games.blank?
      @shared_games[0] = "No shared games!"
    end

    render :with_friend
  end

  def multi_compare
    @user = session[:current_user]
    @friends_name = []
    friends_uid = []
    shared_games_ids = []
    p params[:friends]
    params[:friends].each do |friend|
      friend_name = SteamScripts.friend_summary_name(friend)
      @friends_name << friend_name
      if shared_games_ids.blank?
        shared_games_ids = SteamScripts.shared_games(SteamScripts.games_list(session[:current_user]['uid']), SteamScripts.games_list(friend))
      else
        shared_games_ids = SteamScripts.shared_games(shared_games_ids, SteamScripts.games_list(friend))
      end
    end
    @shared_games = []
    @shared_games = SteamScripts.shared_games_names(shared_games_ids)
    if @shared_games.blank?
      @shared_games[0] = "No shared games!"
    end

    render :multi_compare
  end

  private

end
