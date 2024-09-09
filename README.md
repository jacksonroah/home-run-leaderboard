# 2024 Home Run Derby Shiny App
[Home Run Derby Leaderboard Website](https://jacksonroah.shinyapps.io/hr_derby_2024/)

## Project Overview
This Shiny app provides a real-time dashboard for tracking home runs in a fantasy baseball league's 2024 Home Run Derby. The app features live updates, team standings, player statistics, and a cumulative home run graph over time.

## Features
- **Live Data Updates**: Fetches and processes real-time data from an external API.
- **Team Standings**: Displays current standings with custom styling for each team.
- **Player Statistics**: Shows detailed home run stats for each player, highlighting top performers.
- **Interactive Graph**: Visualizes cumulative home runs over time for each team.
- **Optimized Design for Mobile**: Targeted users only view website on mobile, so design is centered there

## Technologies Used
- R
- Shiny
- ggplot2
- dplyr
- tidyr
- DT (DataTables)
- httr
- jsonlite

## Project Structure
- `app.R`: Main Shiny app file that sources other components.
- `data_processing.R`: Contains functions for data fetching, processing, and calculations.
- `server.R`: Defines the server logic for the Shiny app.
- `ui.R`: Defines the user interface for the Shiny app.

## Setup and Running the App
1. Clone this repository.
2. Ensure you have R and the required packages installed.
3. Run the app using RStudio or by executing `R -e "shiny::runApp()"` in the project directory.

## Future Improvements
- Implement user authentication for personalized views.
- Add more advanced statistics and predictive models.
- Enhance mobile responsiveness for better small-screen experiences.

## Contact
Jackson Roah - [jackson@roah.com](mailto:jackson@roah.com)


Project Link: [https://jacksonroah.shinyapps.io/hr_derby_2024/](https://jacksonroah.shinyapps.io/hr_derby_2024/)
