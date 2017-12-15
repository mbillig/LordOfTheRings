#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(ggplot2)
library(reshape2)
library(DT)
library(shinycssloaders)
source("getTopicModels.R")


# Define UI for application that draws a histogram
ui <- fluidPage(
   
   # Application title
   titlePanel("Tolkien Topic Analysis"),
   h4('Patience please - analysis may take up to a minute'),
   
   # Sidebar with a slider input for number of bins 
   sidebarLayout(
      sidebarPanel(
        checkboxGroupInput("corpus", 
                    "Select works to include in corpus:",
                    choices = list("The Hobbit" = "hobbit", 
                                   "The Fellowship of the Ring: Book 1" = "book1",
                                   "The Fellowship of the Ring: Book 2" = "book2",
                                   "The Two Towers: Book 3" = "book3",
                                   "The Two Towers: Book 4" = "book4",
                                   "Return of the King: Book 5" = "book5",
                                   "Return of the King: Book 6" = "book6",
                                   "The Silmarillion" = "silmarillion",
                                   "Complete Texts (not by chapter)" = "complete_texts"
                                   ),selected = c("book1","book2","book3","book4","book5","book6")), 
        sliderInput("topics",
                     "Number of Topics:",
                     min = 0,
                     max = 50,
                     value = 5),
         sliderInput("optimize",
                     "Select an Omptimization Index:",
                     min = 0,
                     max = 50,
                     value = 20),
        actionButton("update",
                     "Update Plot"
        )
      ),
      
      # Show a plot of the generated distribution
      mainPanel(
         withSpinner(plotOutput("distPlot")),
         
         dataTableOutput("topicsTable")
      )
   )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
   
  getTopicDist <- eventReactive(input$update, {
    corpus = input$corpus
    print(corpus)
    multipleSelected = (length(corpus) > 1)
    isSelected = !is.na(match('complete_texts', corpus))
    validSelection = TRUE
    if(isSelected){
      if(multipleSelected){
        validSelection = FALSE
      }else{
        validSelection = TRUE
      }
    }
    validate(
      need(validSelection, "Complete Texts option cannot be selected with other texts")
    ) 
    validate(
      need(length(corpus) != 0, "Please select at least one body of work")
    )
    
    nTopics = input$topics
    optInt = input$optimize
    
    TopicDist = getTopicModels(nTopics, optInt, corpus)
  }, ignoreNULL = FALSE)
  
  selectedTopics <- eventReactive(input$topicsTable_rows_selected, {
    selectedTopics = input$topicsTable_rows_selected
  }, ignoreNULL = FALSE)
  
   output$distPlot <- renderPlot({
     
      TopicDist = getTopicDist()
      topics = TopicDist[,c(1,2)]
      dists = data.frame(t(TopicDist[,c(3:ncol(TopicDist))]))
      
      section = 1:nrow(dists)
      dists = cbind(section, dists)
      
      dfl <- melt(dists, id.vars = 'section', variable.names = 'series')
      
      selTopics = selectedTopics()
      if(is.null(selTopics)) selTopics = c(0)
      
      isTopicSelected = rep(1, nrow(dfl))
      for (i in 1:nrow(dfl)){
        if(is.element(as.numeric(dfl$variable[i]), selTopics)){
          isTopicSelected[i] = 2.5
        }
      }
      
      ggplot(dfl, aes(section, value)) + geom_line(aes(colour = variable, size = isTopicSelected)) +
        scale_size_identity() 

   })
   
   output$topicsTable <- renderDataTable({
     TopicDist = getTopicDist()
     topics = TopicDist[,c(1,2)]
     datatable(topics)
   })
}

# Run the application 
shinyApp(ui = ui, server = server)

