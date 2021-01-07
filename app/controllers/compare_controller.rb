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
    @friend = friend_summary(params[:friend])
    render :with_friend
  end

  private

  def friends_list(uid)
    uid = uid
    friend_list_link = "http://api.steampowered.com/ISteamUser/GetFriendList/v0001/?key=#{ENV['STEAM_API_KEY']}&steamid=#{uid}&relationship=friend"
    uri = URI.open(friend_list_link)
    friend_list_json = JSON.parse uri.read
    friend_list_json_raw = friend_list_json['friendslist']['friends']
    friend_list_full = {}

    friend_list_json_raw.each do |friend|
      friend_id = friend['steamid']
      friend_name = friend_summary(friend_id)
      friend_list_full[friend_id] = friend_name
    end

    return friend_list_full
  end

  def friend_summary(uid)
    uid = uid
    summary_link = "http://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=#{ENV['STEAM_API_KEY']}&steamids=#{uid}"
    uri = URI.open(summary_link)
    friend_summary = JSON.parse uri.read
    friend_name = friend_summary['response']['players'][0]['personaname']
  end

end
