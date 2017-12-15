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
                     min = 2,
                     max = 50,
                     value = 10),
         sliderInput("optimize",
                     "Select an Omptimization Index:",
                     min = 0,
                     max = 50,
                     value = 20)
      ),
      
      # Show a plot of the generated distribution
      mainPanel(
         withSpinner(plotOutput("distPlot"))
      )
   )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
   
   output$distPlot <- renderPlot({
     
     corpus = input$corpus
     print(corpus)
     multipleSelected = (length(corpus) > 1)
     isSelected = !is.na(match('complete_texts', corpus))
     validate(
        need((!multipleSelected & isSelected) | (!isSelected & multipleSelected), "Complete Texts option cannot be selected with other texts")
      ) 
     
      nTopics = input$topics
      optInt = input$optimize
      
      TopicDist = getTopicModels(nTopics, optInt, corpus)
      topics = TopicDist[,c(1,2)]
      dists = data.frame(t(TopicDist[,c(3:ncol(TopicDist))]))
      topicNames = c("Topic 1")
      for (i in 2:ncol(dists)){
        topicNames = c(topicNames, paste("Topic ", i, sep = ""))
      }
      names(dists) = topicNames
      section = 1:nrow(dists)
      dists = cbind(section, dists)
      
      dfl <- melt(dists, id.vars = 'section', variable.names = 'series')
      
      ggplot(dfl, aes(section, value)) + geom_line(aes(colour = variable))

   })
}

# Run the application 
shinyApp(ui = ui, server = server)

