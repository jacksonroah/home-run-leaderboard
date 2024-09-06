library(shiny)
library(DT)

ui <- fluidPage(
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "styles.css"),
    tags$style(HTML("
      .team-totals-container {
        display: flex;
        flex-wrap: wrap;
        justify-content: space-between;
      }
      
      .team-totals-box {
        flex: 1 1 calc(50% - 10px);
        margin: 5px;
        border: 1px solid #ddd;
        padding: 10px;
        background-color: #f9f9f9;
      }
      .team-total {
        font-size: 1.2em;
        font-weight: bold;
        margin-top: 10px;
        background-color: #e0e0e0;
        padding: 10px;
      }
      .top-5 {
        background-color: #ffffcc !important; /* Light yellow */
      }
      .bottom-2 {
        background-color: #f0f0f0 !important; /* Light grey */
        color: #a0a0a0 !important;
      }
      .total-row {
        background-color: #e0e0e0 !important;
        font-weight: bold;
        font-size: 1.1em;
      }
      .team-derek {
        background-color: #E6C085 !important;
      }
      .team-jackson {
        background-color: #008080 !important;
      }
      .team-tyler {
        background-color: #5A3E9B !important;
      }
      .team-jason {
        background-color: #8B0000 !important;
      }
      .dataTables_wrapper .dataTables_scrollHeadInner th {
        text-align: center !important;
      }
      @media (max-width: 600px) {
        .team-totals-box {
          flex: 1 1 100%;
        }
      }
    "))
  ),
  titlePanel("2024 Home Run Derby"),
  
  # Team totals leaderboard
  h2("Current Standings:"),
  DTOutput("team_totals"),
  
  # Individual player stats
  h2("Team Home Run Totals"),
  uiOutput("player_stats"),
  
  # Graph of team totals over time
  h2("Team Totals Over Time"),
  plotOutput("hr_graph")
)
