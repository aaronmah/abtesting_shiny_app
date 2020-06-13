#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(

    # Application title
    br(),
    titlePanel( h1("AB Test - Significance Calculator", align="center")),
    hr(),

    # Sidebar with a slider input for number of bins
    sidebarLayout(
        sidebarPanel(
            tags$b("Is your test significant?"),
            tags$p("Toggle the controls to evaluate your AB test results and identify whether the change in conversion rates are meaningfully different."),
            br(),
            numericInput("sampleA", "Visitors A", value="8000", min=0),
            numericInput("conversionsA", "Conversions A", value="500", min=0 ),
            numericInput("sampleB", "Visitors B", value="8000", min=0),
            numericInput("conversionsB", "Conversions B", value="600", min=0 ),
            br(),
            radioButtons("testtype", "Alternative Hypothesis:", c("Two-Sided"="two.sided", "Greater Than"="greater", "Less Than"="less")),

            br(),
            sliderInput("conf", "Confidence Level", 90,99,value=95),
            submitButton("Submit", width='100%'),
        ),

        # Show a plot of the generated distribution
        mainPanel(
            plotOutput("abPlot"),
            hr(),
            column(4,
                   h4("Conversion Rate A"),
                   textOutput("conversionRateA")
                   ),
            column(4,
                   h4("Conversion Rate B"),
                   textOutput("conversionRateB")
                   ),
            column(4,
                   h4("Relative Uplift"),
                   textOutput("relUplift")

                   ),
            column(4,
                   h4("P value"),
                   textOutput("pval")
                   ),
            column(4,
                   h4("Standard Error A"),
                   textOutput("seA")
            ),
            column(4,
                   h4("Standard Error B"),
                   textOutput("seB")
            ),

            br(),
            hr(),
            column(12,
                   br(),
                   hr(),
                   h4("Results:"),
                   textOutput("results")
                   )



        ),


    )
))
