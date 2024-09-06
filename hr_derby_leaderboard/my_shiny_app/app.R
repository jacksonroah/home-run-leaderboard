# app.R
library(shiny)

# Source external scripts
source("data_processing.R")
source("ui.R")
source("server.R")

# Create Shiny app
shinyApp(ui = ui, server = server)
