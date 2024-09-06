library(jsonlite)
library(dplyr)
library(httr)

# Fetch data function
fetch_data <- function(url) {
  response <- GET(url)
  data <- fromJSON(content(response, "text"))
  return(data)
}

# Example drafted players data frame
drafted_players <- data.frame(
  player_id = 1:28,
  player_name = c("Kyle Tucker", "Marcell Ozuna", "José Ramírez", "Teoscar Hernández", "Adley Rutschman", "Josh Naylor", "Ty France",
                  "Shohei Ohtani", "Corey Seager", "Pete Alonso", "Cal Raleigh", "Elly De La Cruz", "Matt Olson", "Max Muncy",
                  "Aaron Judge", "Giancarlo Stanton", "Yordan Alvarez", "Adolis García", "Rafael Devers", "Freddie Freeman", "Fernando Tatis Jr.",
                  "Juan Soto", "Bryce Harper", "Gunnar Henderson", "Kyle Schwarber", "Christian Walker", "Brent Rooker", "Ryan McMahon"), 
  team_name = c("Jackson", "Jackson", "Jackson", "Jackson", "Jackson", "Jackson", "Jackson", 
                "Tyler", "Tyler", "Tyler", "Tyler", "Tyler", "Tyler", "Tyler",
                "Derek", "Derek", "Derek", "Derek", "Derek", "Derek", "Derek",
                "Jason", "Jason", "Jason", "Jason", "Jason", "Jason", "Jason")
)

# Process data function
process_data <- function(data, drafted_players) {
  df <- data.frame(
    player_name = data$batter_name,
    date = as.Date(data$date),
    total_home_runs = as.numeric(as.character(data$player_hr_num))
  )
  
  # Remove rows where conversion to numeric failed
  df <- df[!is.na(df$total_home_runs), ]
  
  combined_data <- drafted_players %>%
    inner_join(df, by = "player_name")
  
  return(combined_data)
}

# Calculate total home runs per player
calculate_total_hr_per_player <- function(data) {
  total_hr_per_player <- data %>%
    group_by(player_id, player_name, team_name) %>%
    summarise(total_home_runs = n(), .groups = 'drop') %>%
    arrange(desc(total_home_runs))
  
  return(total_hr_per_player)
}

# Calculate total home runs per team
calculate_total_hr_per_team <- function(player_data) {
  total_hr_per_team <- player_data %>%
    group_by(team_name) %>%
    summarise(total_home_runs = sum(total_home_runs), .groups = 'drop') %>%
    arrange(desc(total_home_runs))
  
  return(total_hr_per_team)
}

# Create leaderboard function
create_leaderboard <- function(total_hr_per_player) {
  # Get top 5 players per team
  top_5_per_team <- total_hr_per_player %>%
    group_by(team_name) %>%
    arrange(desc(total_home_runs)) %>%
    slice(1:5) %>%
    ungroup()
  
  # Get all players per team
  all_players_per_team <- total_hr_per_player %>%
    group_by(team_name) %>%
    arrange(desc(total_home_runs)) %>%
    ungroup()
  
  # Calculate totals for top 5 and all players
  top_5_totals <- top_5_per_team %>%
    group_by(team_name) %>%
    summarise(top_5_total = sum(total_home_runs), .groups = 'drop')
  
  all_players_totals <- all_players_per_team %>%
    group_by(team_name) %>%
    summarise(all_players_total = sum(total_home_runs), .groups = 'drop')
  
  # Merge results
  leaderboard <- top_5_totals %>%
    left_join(all_players_totals, by = "team_name")
  
  return(list(top_5_per_team = top_5_per_team, leaderboard = leaderboard))
}

# Calculate daily top 5 home runs per team
calculate_daily_top_5_hr_per_team <- function(data) {
  data %>%
    group_by(team_name, date, player_name) %>%
    summarise(daily_hr = sum(total_home_runs), .groups = 'drop') %>%
    arrange(team_name, date, desc(daily_hr)) %>%
    group_by(team_name, date) %>%
    slice(1:5) %>%
    summarise(top_5_daily_hr = sum(daily_hr), .groups = 'drop')
}
