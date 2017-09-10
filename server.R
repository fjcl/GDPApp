# Load libraries
library(shiny)
library(ggplot2)
library(dplyr)
library(maps)
library(markdown)
library(rCharts)
library(mapproj)

# Load World Map
worldMap <- map_data("world2")

# Load mapping between country names in world map and World Bank GDP
countryNamesMap <- read.csv("data/CountryNames.csv", sep=";")

# Load and process GDP data
gdp <- read.csv("data/World Bank GDP.csv", sep=";", check.names=FALSE, dec=",",
                colClasses=c(rep("character", 4), rep("numeric", 57)))
gdp[,2:4] <- NULL
gdp$mapCountryName <- countryNamesMap$Map[match(gdp$`Country Name`, countryNamesMap$WorldBank)]
gdp <- gdp[which(gdp$`mapCountryName`!= ""),]
worldGDP <- data.frame(cbind(seq(1960, 2016, 1), colSums(gdp[,c(2:58)], na.rm=TRUE)))
colnames(worldGDP) <- c("year", "GDP")

# Function to visualize World GDP evolution
plotWorldGDP <- function(dt) {
        ggplot(worldGDP, aes(x=year, y=GDP/1e12)) +
                geom_point(color="red") +
                geom_smooth() +
                labs(title="World GDP (current USD)", x="Year", y = "GDP in Trillions")
}

# Function to visualize GDP World Map
plotGDPByYear <- function (dt, year, low = "#fff5eb", high = "#d94801") {
        colnames(dt)[2] <- "GDP"
        dt$GDP <- dt$GDP / 1e9
        title <- sprintf("GDP %s in Billions current USD", year)
        p <- ggplot(dt, aes(map_id = mapCountryName))
        p <- p + geom_map(aes_string(fill = "GDP"), map = worldMap, colour='black')
        p <- p + expand_limits(x = worldMap$long, y = worldMap$lat)
        p <- p + coord_map() + theme_bw()
        p <- p + labs(x = "Long", y = "Lat", title = title)
        p + scale_fill_continuous(low = low, high = high)
}

# Shiny server 
shinyServer(function(input, output, session) {
        
        # Define and initialize reactive values
        values <- reactiveValues()
        
        # Reactive expression for GDP data by Year
        gdpByYear <- reactive({
                gdp[, c("mapCountryName", input$year)]
        })
        
        # Reactive expression for GDP data filtered by country
        gdpFilterCountry <- reactive({
                gdp[grepl(paste("^", input$country, sep=""), gdp$`Country Name`),-59]
        })
        
        # Render Time Evolution
        output$worldGDP <- renderPlot({
                plotWorldGDP(worldGDP)
        })
        
        # Render World Map
        output$gdpByYear <- renderPlot({
                plotGDPByYear (dt=gdpByYear(), input$year)
        })
        
        # Render Data
        output$table <- renderDataTable(
                {gdpFilterCountry()}, options = list(bFilter = FALSE, iDisplayLength = 10))
        
        # Download Handler
        output$downloadData <- downloadHandler(
                filename = "GDP.csv",
                content = function(file) {
                        write.csv({gdpFilterCountry()}, file, row.names=TRUE)
                }
        )
})
