#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(dbplyr)
library(dplyr)
library(shiny)
library(ggplot2)
library(shinydashboard)
source('./Queries.R')




ui <- dashboardPage(
  ## Header content ##
  dashboardHeader(title = "Basic dashboard"),
  
  
  ## Sidebar content ## 
  dashboardSidebar(
    sidebarMenu(
      menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
      menuItem("Widgets", tabName = "widgets", icon = icon("th"))
    )
  ),
  
  
  ## Body content ##
  dashboardBody(
    tabItems(
      # First tab content
      tabItem(tabName = "dashboard",
              fluidRow(
                    sidebarPanel(sliderInput(
                      "bins",
                      "Number of bins:",
                      min = 1,
                      max = 50,
                      value = 30
                    ),
                    checkboxGroupInput(
                      "country",
                      "Select a country",
                      c("The Netherlands" = '1', "Brazil" = '4', "China" = '3', "United Kingdom" = '2'),
                      selected = '2'
                    )),
                    
                      # Show a plot of the generated distribution
                      mainPanel(
                        h4("Test Table Distinct Values"),
                        tableOutput("view"),

                        plotOutput("distPlot"),
                        plotOutput("countryPlot")
                      )
  
                
                
              )
      ),
      
      # Second tab content
      tabItem(tabName = "widgets",
              h2("Widgets tab content")
      )
    )
  )
)

server <- function(input, output, session) {
    output$distPlot <- renderPlot({
      # generate bins based on input$bins from ui.R
      x    <- faithful[, 2]
      bins <- seq(min(x), max(x), length.out = input$bins + 1)



      # draw the histogram with the specified number of bins
      hist(x,
           breaks = bins,
           col = 'darkgray',
           border = 'white')
    })

    # This is a test using our data
    output$countryPlot <- renderPlot({
        selectedCountries <- input$country
        displayData <- GetAmountOfPapersPublishedForCountries() %>% filter(country_id %in% selectedCountries) %>% collect()
        output <- ggplot(data=displayData, aes(x=country_name, y=total_papers_published)) +
          geom_bar(stat="identity", fill="steelblue") + theme_minimal()
        output
    })
    
    #This is the DEMO
    # output$countryPlot <- renderPlot({
    #   selectedCountries <- input$country
    #   displayData <- PercentageOfPopulationWorkingInScience() %>% filter(country_id %in% selectedCountries) %>% collect()
    #   output <- ggplot(data=displayData, aes(x=year_id, y=value, fill=country_id)) +
    #     geom_bar(stat="identity") + xlab("Year") + ylab("Percentage of Population")
    #   output + scale_color_brewer(palette = "Dark2")
    # })

    # output$view <- renderTable({
    #   head(TestDatabase())
    # })

    #Closes the connection when the app is not running anymore
    session$onSessionEnded(function() {
      CloseConnection(DATABASE)
    })
  }

# Run the application
shinyApp(ui, server)
