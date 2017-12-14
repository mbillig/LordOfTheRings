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

# Define UI for application that draws a histogram
ui <- fluidPage(
   
   # Application title
   titlePanel("Tolkien Topic Analysis"),
   h4('Patience please - analysis takes about 30 seconds'),
   
   # Sidebar with a slider input for number of bins 
   sidebarLayout(
      sidebarPanel(
        radioButtons("corpus", 
                    "Select a body of text",
                    choices = list("Lord of the Rings Trilogy" = 1, 
                                   "LOTR, the Hobbit, and the Silmarillion" = 2),selected = 1), 
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
      
      nTopics = input$topics
      corpusIndex = input$corpus
      optInt = input$optimize
      
      TopicDist = getTopicModels(nTopics, optInt, corpusIndex)
      topics = TopicDist[,c(1,2)]
      dists = data.frame(t(TopicDist[,c(3:ncol(TopicDist))]))
      index = 1:nrow(dists)
      dists = cbind(index, dists)
      
      dfl <- melt(dists, id.vars = 'index', variable.names = 'series')
      
      ggplot(dfl, aes(index, value)) + geom_line(aes(colour = variable))
      # draw the histogram with the specified number of bins
      #hist(x, breaks = bins, col = 'darkgray', border = 'white')
   })
}

# Run the application 
shinyApp(ui = ui, server = server)

