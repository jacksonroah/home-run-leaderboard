library(shiny)
library(ggplot2)
library(dplyr)
library(tidyr)
library(DT)
library(httr)
library(jsonlite)

# Source the data_processing.R file
source("data_processing.R")

# Define the URL of the JSON data
json_url <- "https://zuriteapi.com/homers/api/homeruns/?format=json&year=2024"

# Define the interval for polling in milliseconds (e.g., 60000 ms = 1 minute)
poll_interval <- 60000

server <- function(input, output, session) {
  # Reactive polling function to fetch data
  data <- reactivePoll(poll_interval, session,
                       checkFunc = function() {
                         tryCatch({
                           httr::GET(json_url)$headers$date
                         }, error = function(e) {
                           Sys.time()
                         })
                       },
                       valueFunc = function() {
                         tryCatch({
                           raw_data <- httr::GET(json_url)
                           data <- jsonlite::fromJSON(httr::content(raw_data, "text"))
                           process_data(data, drafted_players)
                         }, error = function(e) {
                           NULL
                         })
                       }
  )
  
  # Calculate total home runs per player
  total_hr_per_player <- reactive({
    if (is.null(data())) return(NULL)
    calculate_total_hr_per_player(data())
  })
  
  # Create leaderboard
  leaderboard_data <- reactive({
    if (is.null(total_hr_per_player())) return(NULL)
    leaderboard <- create_leaderboard(total_hr_per_player())
    leaderboard$leaderboard <- leaderboard$leaderboard %>% arrange(desc(top_5_total))
    leaderboard
  })
  
  output$team_totals <- renderDT({
    if (is.null(leaderboard_data())) return(NULL)
    
    # Define colors and text colors for each team
    team_colors <- list(
      "Derek" = "#CFB87C",   # Brighter University of Colorado Boulder Gold
      "Jackson" = "#008080", # Brighter Mariners Teal
      "Tyler" = "#4b2e83",   # Brighter University of Washington Purple
      "Jason" = "#8B0000"    # Brighter University of South Carolina Red
    )
    text_colors <- list(
      "Derek" = "black",
      "Jackson" = "#C4CED4",
      "Tyler" = "#e8e3d3",
      "Jason" = "white"
    )
    
    # Get the leaderboard data and arrange by top_5_total
    leaderboard <- leaderboard_data()$leaderboard %>%
      mutate(Rank = row_number()) %>%
      select(Rank, Team = team_name, `TOP 5` = top_5_total, Total = all_players_total) %>%
      arrange(Rank)
    
    datatable(leaderboard, 
              options = list(dom = 't', pageLength = -1, autoWidth = TRUE, ordering = FALSE, searching = FALSE, paging = FALSE), 
              rownames = FALSE, escape = FALSE) %>%
      formatStyle(
        columns = names(leaderboard),
        backgroundColor = styleEqual(leaderboard$Team, sapply(leaderboard$Team, function(team) team_colors[[team]])),
        color = styleEqual(leaderboard$Team, sapply(leaderboard$Team, function(team) text_colors[[team]])),
        textAlign = 'center'
      ) %>%
      formatStyle(
        columns = colnames(leaderboard),
        fontWeight = 'bold',
        textAlign = 'center',
        verticalAlign = 'middle'
      )
  })
  
  
  
  
  # Ensure this is inside the server function
  outputOptions(output, "team_totals", suspendWhenHidden = FALSE)
  
  # Render individual player stats with total rows
  output$player_stats <- renderUI({
    if (is.null(total_hr_per_player())) return(NULL)
    teams <- unique(total_hr_per_player()$team_name)
    
    # Define colors for each team
    team_colors <- list(
      "Derek" = "#CFB87C",   # University of Colorado Boulder Gold
      "Jackson" = "#005C5C", # Mariners Teal
      "Tyler" = "#4b2e83",   # University of Washington Purple
      "Jason" = "#73000A"    # University of South Carolina Red
    )
    
    team_stats <- lapply(teams, function(team) {
      team_color <- team_colors[[team]]
      highlight_color <- adjustcolor(team_color, alpha.f = 0.5)  # Lighter shade of the team color
      
      team_data <- total_hr_per_player() %>%
        filter(team_name == team) %>%
        arrange(desc(total_home_runs)) %>%
        mutate(rank = as.character(row_number()),  # Convert to character to match total_row
               class = case_when(
                 as.integer(rank) <= 5 ~ "top-5",
                 as.integer(rank) > 5 & as.integer(rank) <= 7 ~ "bottom-2",
                 TRUE ~ NA_character_
               )) %>%
        select(rank, `Player Name` = player_name, `HR` = total_home_runs, class)
      
      top_5_total <- team_data %>%
        filter(as.integer(rank) <= 5) %>%
        summarise(top_5_total = sum(`HR`)) %>%
        pull(top_5_total)
      
      all_players_total <- team_data %>%
        summarise(all_players_total = sum(`HR`)) %>%
        pull(all_players_total)
      
      total_row <- data.frame(
        rank = c("", ""),
        `Player Name` = c("Top 5 Total", "Team Total"),
        `HR` = c(top_5_total, all_players_total),
        class = c("total-row", "total-row"),
        stringsAsFactors = FALSE
      )
      
      # Ensure column names are consistent
      total_row <- total_row %>% rename(`Player Name` = Player.Name)
      
      team_data <- bind_rows(team_data, total_row)
      
      table_rows <- apply(team_data, 1, function(row) {
        row_class <- row["class"]
        row_style <- ""
        if (row_class == "top-5") {
          row_style <- paste0("background-color: ", highlight_color, " !important;")  # Lighter shade
        } else if (row_class == "bottom-2") {
          row_style <- "background-color: #f0f0f0 !important; color: #a0a0a0 !important;"  # Light grey
        } else if (row_class == "total-row") {
          row_style <- paste0("background-color: ", team_color, " !important; font-weight: bold; color: white !important;")  # Team color with bold text and white color
        }
        paste0("<tr style='", row_style, "'><td>", row["rank"], "</td><td>", row["Player Name"], "</td><td>", row["HR"], "</td></tr>")
      })
      
      table_content <- paste(table_rows, collapse = "")
      
      div(
        h3(team),
        HTML(paste0(
          "<table class='team-table' style='border-collapse: collapse; width: 100%;'><thead><tr style='background-color:", team_color, "; color: white;'><th>Rank</th><th>Player Name</th><th>HR</th></tr></thead><tbody>",
          table_content,
          "</tbody></table>"
        ))
      )
    })
    
    do.call(tagList, team_stats)
  })
  
  cumulative_hr_data <- reactive({
    if (is.null(data())) return(NULL)
    data() %>%
      mutate(date = as.Date(date)) %>% # Ensure date is in Date format
      group_by(team_name, player_name) %>%
      summarise(total_hr = n(), .groups = 'drop') %>%
      arrange(team_name, desc(total_hr)) %>% # Order by team and descending home runs
      group_by(team_name) %>%
      slice_head(n = 5) %>% # Keep only the top 5 players per team
      ungroup() %>%
      inner_join(data(), by = c("team_name", "player_name")) %>% # Join back with original data to retain date information
      group_by(team_name, date) %>%
      summarise(daily_hr = n(), .groups = 'drop') %>%
      arrange(team_name, date) %>%
      group_by(team_name) %>%
      mutate(cumulative_hr = cumsum(daily_hr)) %>%
      ungroup()
  })
  
  
  
  # Render home run graph over time
  output$hr_graph <- renderPlot({
    if (is.null(cumulative_hr_data())) return(NULL)
    
    # Calculate the current standings
    standings <- leaderboard_data()$leaderboard %>%
      arrange(desc(top_5_total))
    
    # Define brighter colors for each team
    team_colors <- c(
      "Derek" = "#E6C085",   # Brighter University of Colorado Boulder Gold
      "Jackson" = "#008080", # Brighter Mariners Teal
      "Tyler" = "#5A3E9B",   # Brighter University of Washington Purple
      "Jason" = "#8B0000"    # Brighter University of South Carolina Red
    )
    
    # Reorder the levels of team_name based on the current standings
    cumulative_hr_data_reordered <- cumulative_hr_data() %>%
      mutate(team_name = factor(team_name, levels = standings$team_name))
    
    ggplot(cumulative_hr_data_reordered, aes(x = date, y = cumulative_hr, color = team_name)) +
      geom_line(size = 1.5) +
      geom_vline(xintercept = as.Date("2024-06-03"), linetype = "dashed", color = "red") +
      annotate("text", x = as.Date("2024-06-03"), y = max(cumulative_hr_data()$cumulative_hr), label = "Draft Day", hjust = 1, vjust = 2, angle = 0, color = "red") +
      labs(title = "Cumulative Home Runs Over Time by Team", x = "Date", y = "Cumulative Home Runs") +
      scale_color_manual(values = team_colors) +
      theme_minimal() +
      theme(
        legend.title = element_blank(),
        legend.position = "top",
        legend.direction = "horizontal"
      )
  })
  
  
}