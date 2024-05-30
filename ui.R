library(shiny)
library(ggplot2)
library(flexdashboard)
library(bslib)
library(dplyr)
library(markdown)

setwd("C:/Users/mrche/info201/final-project-anguyenuw")

countries <- read.csv("csvfiles/user_data/users_with_RME.csv") %>%
  select(Location) %>%
  distinct() %>%
  arrange(Location)
  


#p_1 <- sidebarPanel(
  
#  sliderInput('sampleSize', 'Sample Size', min=1, max=nrow(dataset),
 #             value=min(1000, nrow(dataset)), step=500, round=0),
  
#  selectInput('x', 'X', names(dataset)),
 # selectInput('y', 'Y', names(dataset), names(dataset)[[2]]),
 # selectInput('color', 'Color', c('None', names(dataset))),
  
 # checkboxInput('jitter', 'Jitter'),
#  checkboxInput('smooth', 'Smooth'),
  
#  selectInput('facet_row', 'Facet Row', c(None='.', names(dataset))),
#selectInput('facet_col', 'Facet Column', c(None='.', names(dataset)))
#)


#mainPanel(
#  plotOutput('plot')
#)

lb_user_input <- textInput("user_lookup", 
                            label = "Player", 
                            value = "", 
                            placeholder = "Name or ID",
                            width = "100%")
lb_num_rows_input <- div(style="display: inline-block;vertical-align:bottom; width: 45%;",
                         selectInput("user_num_rows", 
                            label = "Players per page", 
                            c(25, 50, 100, 250, 500), 
                            selected = 25,
                            width = "100%"))
lb_page_input <- div(style="display: inline-block;vertical-align:bottom; width: 45%;",
                     numericInput("user_page",
                            label = "Page",
                            value = 1,
                            min = 1,
                            max = 1000,
                            step = 1,
                            width = "100%"))
lb_rank_min_input <- div(style="display: inline-block;vertical-align:middle; width: 45%;", 
                         numericInput("user_rank_min",
                            label = "Min. rank",
                            value = 1,
                            min = 1,
                            step = 1,
                            width = "100%"))
lb_rank_max_input <- div(style="display: inline-block;vertical-align:middle; width: 45%;", 
                         numericInput("user_rank_max",
                            label = "Max. rank",
                            value = 10000000,
                            min = 1,
                            step = 1,
                            width = "100%"))
lb_maps_min_input <- div(style="display: inline-block;vertical-align:middle; width: 45%;", 
                         numericInput("user_maps_min",
                                      label = "Min. maps played",
                                      value = 1,
                                      min = 1,
                                      step = 1,
                                      width = "100%"))
lb_maps_max_input <- div(style="display: inline-block;vertical-align:middle; width: 45%;", 
                         numericInput("user_maps_max",
                                      label = "Max. maps played",
                                      value = 10000,
                                      min = 1,
                                      step = 1,
                                      width = "100%"))
lb_location_input <- selectInput(
                            "user_locations",
                            "Location(s)",
                            countries,
                            multiple = TRUE,
                            width = "100%")
empty <- div(style="display: inline-block;vertical-align:middle; width: 5%;", "")
lb_params_input <- sidebarPanel(h3("Search"), 
                          lb_user_input, 
                          lb_num_rows_input, empty, lb_page_input,
                          lb_rank_min_input, empty, lb_rank_max_input,
                          lb_maps_min_input, empty, lb_maps_max_input,
                          lb_location_input,
                          width = 3)

lb_table <- mainPanel(tableOutput('lb_user_tbl'))



ui <- page_navbar(
  title = "Rhythm Metrics Elo",
  theme = bs_theme(version = 5, bootswatch = "minty"),
  #bg = "#2D89C8",
  inverse = TRUE,
  
  # TODO: use includeMarkdown()
  nav_panel(title = "Homepage", includeMarkdown("homepage.md")),
  nav_panel(title = "Leaderboard", 
            list(sidebarLayout(lb_params_input, lb_table))
  ),
  nav_panel(title = "RME Distribution", p("RME Distribution"), textOutput("yes")),
  nav_panel(title = "Three", p("Third page content.")),
  nav_spacer(),
  nav_menu(
    title = "Other",
    align = "right",
    nav_item(tags$a("Source code", href = "https://github.com/info-201b-sp24/final-project-anguyenuw")),
    nav_item(tags$a("Created with Shiny", href = "https://shiny.posit.co"))
  ),
  
  #titlePanel("Diamonds Explorer"),
  
  
)


fluidPage(ui
)