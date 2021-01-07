require "json"
require "open-uri"

class CompareController < ApplicationController

  def index
    @user = session[:current_user]
    @friends = friends_list(session[:current_user]['uid'])
    render :index
  end

  def with_friend
    @user = session[:current_user]
    @friend_uid = params[:friend]
    @friend_name = friend_summary_name(@friend_uid)
    @shared_games = shared_games(games_list(session[:current_user]['uid']), games_list(@friend_uid))
    render :with_friend
  end

  private

  def friends_list(uid)
    uid = uid
    friend_list_link = "http://api.steampowered.com/ISteamUser/GetFriendList/v0001/?key=#{ENV['STEAM_API_KEY']}&steamid=#{uid}&relationship=friend"
    uri = URI.open(friend_list_link)
    friend_list_raw = JSON.parse uri.read
    friend_list = friend_list_raw['friendslist']['friends']
    friend_list_full = {}

    friend_list.each do |friend|
      friend_id = friend['steamid']
      friend_name = friend_summary_name(friend_id)
      friend_list_full[friend_id] = friend_name
    end

    return friend_list_full
  end

  def friend_summary_name(uid)
    uid = uid
    summary_link = "http://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=#{ENV['STEAM_API_KEY']}&steamids=#{uid}"
    uri = URI.open(summary_link)
    friend_summary_raw = JSON.parse uri.read
    friend_name = friend_summary_raw['response']['players'][0]['personaname']

    return friend_name
  end

  def games_list(uid)
    uid = uid
    games_link = "http://api.steampowered.com/IPlayerService/GetOwnedGames/v0001/?key=#{ENV['STEAM_API_KEY']}&steamid=#{@friend_uid}&format=json"
    uri = URI.open(games_link)
    games_raw = JSON.parse(uri.read)['response']['games']
    games = []

    games_raw.each do |g|
      games << g['appid']
    end

    return games
  end

  def shared_games(user_games, friend_games)
    shared_games_ids = user_games & friend_games
    app_hash = steam_hash_db()
    shared_games = []

    shared_games_ids.each do |g|
      next if app_hash[g].nil?

      shared_games << app_hash[g]
    end

    shared_games.sort!
  end

  def steam_hash_db
    uri = URI.open('http://api.steampowered.com/ISteamApps/GetAppList/v0002/')
    steam_json_file = JSON.parse uri.read
    steam_json_file_raw = steam_json_file['applist']['apps']
    steam_data = {}

    steam_json_file_raw.each do |app|
      if app.nil?
      else
        steam_data[app['appid']] = app['name']
      end
    end

    return steam_data
  end

end
