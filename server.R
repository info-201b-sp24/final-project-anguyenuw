library(shiny)
library(ggplot2)
library(rsconnect)
library(tidyr)

base_table <- read.csv("csvfiles/user_data/users_with_RME.csv")
#base_scores <- read.csv("csvfiles/mp_data/cleaned_scores.csv")
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
  
  
  eventReactive(
    (input$user_pleft),
    (tbl_start_at <- tbl_start_at + replace_na(as.numeric(input$user_num_rows), 25)))
  
  eventReactive(
    (input$user_pright),
    (stop("help")))
      #tbl_start_at <- tbl_start_at - replace_na(as.numeric(input$user_num_rows), 25)))
  # search users in the Users dataset by username (case insensitive) or user ID
  output$lb_user_tbl <- renderTable({ base_table %>%
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
                                             "Rank" = GlobalRank,
                                             "pp" = PP) %>%
                                      select("RME Rank", Username, RME, "Rank", "pp", "Maps Played", Location) %>%
      
                                      slice(1:(n = replace_na(as.numeric(input$user_num_rows), 25)))},
                                      #head(n = replace_na(as.numeric(input$user_num_rows), 25)) },  
                            striped = TRUE,  
                            spacing = 'xs', 
                            digits = 1,
                            align = 'l',
                            width = '100%')
  
  
  
}