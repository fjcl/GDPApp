
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
# 
# http://www.rstudio.com/shiny/
#

library(shiny)
library(rCharts)

shinyUI(
    navbarPage("Gross Domestic Product Application",
        tabPanel("Explore",
                mainPanel(
                    tabsetPanel(
                        
                        # Time Series
                        tabPanel(p(icon("line-chart"), "Evolution"),
                                 plotOutput("worldGDP")
                        ),
                        
                        # World Map
                        tabPanel(p(icon("map-marker"), "World Map"),
                                 column(4,
                                           wellPanel(
                                                    selectInput("year", "Choose Year",
                                                                seq(1960,2016,1), selected=2016)
                                            )
                                 ),
                                 plotOutput("gdpByYear")
                            ),
                        
                        # Data 
                        tabPanel(p(icon("table"), "Data"),
                                 column(4,
                                        wellPanel(
                                                textInput("country", "Filter Country", "")
                                        )
                                 ),
                                 h4('Country GDP (current USD)', align = "center"),
                                 dataTableOutput(outputId="table"),
                                 downloadButton('downloadData', 'Download'))
                    )
                )
        ),
        
        tabPanel("Help",
            mainPanel(
                includeMarkdown("help.md")
            )
        )
    )
)
