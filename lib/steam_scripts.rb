require 'json'
require 'open-uri'

class SteamScripts
  def self.friends_list(uid)
    friend_list_link = "http://api.steampowered.com/ISteamUser/GetFriendList/v0001/?key=#{ENV['STEAM_API_KEY']}&steamid=#{uid}&relationship=friend"
    uri = URI.parse(friend_list_link).open
    friend_list_raw = JSON.parse uri.read
    friend_list = friend_list_raw['friendslist']['friends']
    friend_list_full = {}

    friend_list.each do |friend|
      friend_id = friend['steamid']
      friend_name = friend_summary_name(friend_id)
      friend_list_full[friend_id] = friend_name
    end

    friend_list_full
  end

  def self.friend_summary_name(uid)
    summary_link = "http://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=#{ENV['STEAM_API_KEY']}&steamids=#{uid}"
    uri = URI.parse(summary_link).open
    friend_summary_raw = JSON.parse uri.read
    friend_summary_raw['response']['players'][0]['personaname']
  end

  def self.games_list(uid, option)
    games_link = "http://api.steampowered.com/IPlayerService/GetOwnedGames/v0001/?key=#{ENV['STEAM_API_KEY']}&steamid=#{uid}&format=json"
    uri = URI.parse(games_link).open
    games_raw = JSON.parse(uri.read)['response']['games']
    steam_hash = steam_hash_db
    games = []

    if games_raw.nil?

    elsif !games_raw.nil? && option == 1
      games_raw.each do |g|
        games << g['appid']
      end

    elsif !games_raw.nil? && option == 2
      games_raw.each do |g|
        games << g
      end
      p games
      games.sort! { |a, b| b['playtime_forever'] <=> a['playtime_forever'] }
      games = games[0..9]

      games.each do |g|
        g['name'] = steam_hash[g['appid']]
        g['time_played'] = g['playtime_forever'] / 60
      end
    end

    games
  end

  def self.shared_games(games_list1, games_list2)
    games_list1 & games_list2
  end

  def self.shared_games_names(shared_games_ids)
    app_hash = steam_hash_db
    shared_games = []

    shared_games_ids.each do |g|
      next if app_hash[g].nil? # skips games with no valid steam ID

      shared_games << app_hash[g]
    end

    shared_games.sort!
  end

  def self.steam_hash_db
    uri = URI.parse('http://api.steampowered.com/ISteamApps/GetAppList/v0002/').open
    steam_json_file = JSON.parse(uri.read)['applist']['apps']
    steam_data = {}

    steam_json_file.each do |app|
      if app.nil?
      else
        steam_data[app['appid']] = app['name']
      end
    end

    steam_data
  end
end
