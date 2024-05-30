library(shiny)
library(ggplot2)
library(rsconnect)
library(tidyr)
library(vroom)
setwd("C:/Users/mrche/info201/final-project-anguyenuw")
base_users <- vroom("csvfiles/Users.csv", col_types = "iciddicTi")
base_scores <- vroom("csvfiles/Scores.csv", col_types = "icTiicci")
tbl_start_at <- 1
function(input, output) {
  
  dataset <- reactive({
    diamonds[sample(nrow(diamonds), input$sampleSize),]
  })
  
  output$plot <- renderPlot({
    
    p <- ggplot(dataset(), aes_string(x=input$x, y=input$y)) + geom_point()
    
    if (input$color != 'None')
      p <- p + aes_string(color=input$color)
    
    facets <- paste(input$facet_row, '~', input$facet_col)
    if (facets != '. ~ .')
      p <- p + facet_grid(facets)
    
    if (input$jitter)
      p <- p + geom_jitter()
    if (input$smooth)
      p <- p + geom_smooth()
    
    print(p)
    
  }, height=700)
  
  
  # search users in the Users dataset by username (case insensitive) or user ID
  output$lb_user_tbl <- renderTable({
                                      base_users %>%
                                        # match name/user id
                                      filter(grepl(casefold(input$user_lookup), casefold(Username)) | 
                                               (input$user_lookup == "") |
                                               (input$user_lookup == UserID),
                                        # num global rank within bounds
                                             GlobalRank >= input$user_rank_min,
                                             GlobalRank <= input$user_rank_max,
                                        # num maps played within bounds
                                             Games >= input$user_maps_min,
                                             Games <= input$user_maps_max,
                                        # location matches
                                             (is.null(input$user_locations)) |
                                               (Location %in% input$user_locations)) %>%
                                      mutate("Maps Played" = Games, 
                                             "RME Rank" = RMERanking, 
                                             "pp Rank" = GlobalRank,
                                             "pp" = PP) %>%
                                      select("RME Rank", Username, RME, "pp Rank", "pp", "Maps Played", Location) %>%
      
                                      slice((max(min(
                                                (input$user_page - 1) * replace_na(as.numeric(input$user_num_rows), 25) + 1, 
                                                nrow(base_users)+1), 1)):
                                            (max(min(
                                                (input$user_page) * replace_na(as.numeric(input$user_num_rows), 25), 
                                                nrow(base_users)+1), 1))
                                            )
                            },
                                      #head(n = replace_na(as.numeric(input$user_num_rows), 25)) },  
                            striped = TRUE,
                            spacing = 'xs',
                            digits = 1,
                            align = 'l',
                            hover = TRUE,
                            width = '100%')
  
  #output$
  
  
  
}