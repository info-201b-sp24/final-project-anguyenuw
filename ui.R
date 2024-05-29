library(shiny)
library(ggplot2)
library(flexdashboard)
library(bslib)
library(dplyr)

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
lb_num_rows_input <- selectInput("user_num_rows", 
                            label = "Number of players to display", 
                            c(25, 50, 100, 250, 500), 
                            selected = 25, 
                            width = "45%")
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
lb_params_input <- sidebarPanel(h3("Search parameters"), 
                          lb_user_input, 
                          lb_num_rows_input, 
                          lb_rank_min_input, empty, lb_rank_max_input,
                          lb_maps_min_input, empty, lb_maps_max_input,
                          lb_location_input,
                          width = 3)
lb_page_left <- actionButton("user_pleft",
                             label = "",
                             icon = icon("left-long"),
                             width = "100px")
lb_page_right <- actionButton("user_pright",
                              label = "",
                              icon = icon("right-long"),
                              width = "100px")
lb_table <- mainPanel(lb_page_left,
                      lb_page_right,
                      tableOutput('lb_user_tbl'))

#<i class="fa-solid fa-left-long"></i>

ui <- page_navbar(
  title = "Rhythm Metrics Elo",
  theme = bs_theme(version = 5, bootswatch = "minty"),
  #bg = "#2D89C8",
  inverse = TRUE,
  
  # TODO: use includeMarkdown()
  nav_panel(title = "Homepage", p("Homepage")),
  nav_panel(title = "RME Leaderboard", 
            list(sidebarLayout(lb_params_input, lb_table))
  ),
  nav_panel(title = "Two", p("Second page content.")),
  nav_panel(title = "Three", p("Third page content.")),
  nav_spacer(),
  nav_menu(
    title = "Links",
    align = "right",
    nav_item(tags$a("Posit", href = "https://posit.co")),
    nav_item(tags$a("Shiny", href = "https://shiny.posit.co"))
  ),
  
  #titlePanel("Diamonds Explorer"),
  
  
)


fluidPage(ui
)