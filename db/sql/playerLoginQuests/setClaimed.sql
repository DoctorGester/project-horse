UPDATE player_login_quests SET claimed = TRUE WHERE steam_id = $1 AND login_quest_id = $2