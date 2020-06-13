#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(pwr)
library(ggplot2)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {

    abstats <- reactive({
        testtype <- switch(input$testtype,
                           two.sided="two.sided",
                           less = "less",
                           greater = "greater")
        prop.test(c(input$conversionsA,input$conversionsB), c(input$sampleA, input$sampleB),alternative=testtype)
    })

    output$abPlot <- renderPlot({


        twoside <- switch(input$testtype,
                           two.sided=TRUE,
                           less = FALSE,
                           greater = FALSE)
        z <- qnorm((1-input$conf/100),lower.tail=twoside)

        crA <- input$conversionsA/input$sampleA
        visitA <- input$sampleA
        errA <- sqrt((crA*(1-crA)/visitA))
        meanA <- input$conversionsA/input$sampleA
        xlowA <- meanA-errA*4
        xhighA <- meanA+errA*4


        crB <- input$conversionsB/input$sampleB
        visitB <- input$sampleB
        errB <- sqrt((crB*(1-crB)/visitB))
        meanB <- input$conversionsB/input$sampleB
        xlowB <- meanB-errB*4
        xhighB <- meanB+errB*4
        confBhigh <- meanB + z*sqrt(meanB*(1-meanB)/visitB)
        confBlow <- meanB - z*sqrt(meanB*(1-meanB)/visitB)


        xlow <- ifelse(xlowA < xlowB, xlowA*.95, xlowB*.95)
        xhigh <- ifelse(xhighA > xhighB, xhighA*1.1, xhighB*1.1)

        yhigh <- ifelse(meanA > meanB, meanA, meanB)

        controlXa <- seq(xlowA, xhighA, by=1/input$sampleA)
        controlYa <- dnorm(controlXa, mean=meanA, sd=errA)

        controlXb <- seq(xlowB, xhighB, by=1/input$sampleB)
        controlYb <- dnorm(controlXb, mean=meanB, sd=errB)

        dfa <- data.frame(X=controlXa, Y=controlYa)
        dfb <- data.frame(X=controlXb, Y=controlYb)

        ggplot(data=dfa, aes(X,Y))+geom_line(color="black",lwd=1)+geom_vline(xintercept=confBlow)+geom_vline(xintercept=confBhigh) + geom_line(data=dfb, colour="blue", lwd=1)+ geom_area(data=dfb,fill="blue", alpha=0.1) +theme_bw()+theme(text=element_text(size=14))



    })
    output$conversionRateA <- renderText({
        c(as.character(input$conversionsA/input$sampleA*100),"%")
    })
    output$conversionRateB <- renderText({
        c(as.character(input$conversionsB/input$sampleB*100),"%")
    })
    output$relUplift <- renderText({
        c(as.character(round((input$conversionsB/input$sampleB-input$conversionsA/input$sampleA)/(input$conversionsA/input$sampleA),4)*100),"%")
    })
    output$pval <- renderText({
        abstats()$p.value
    })
    output$seA <- renderText({
        crA <- input$conversionsA/input$sampleA
        visitA <- input$sampleA
        sqrt((crA*(1-crA)/visitA))
    })
    output$seB <- renderText({
        crB <- input$conversionsB/input$sampleB
        visitB <- input$sampleB
        sqrt((crB*(1-crB)/visitB))
    })

    output$results <- renderText({
        results <- ifelse(abstats()$p.value >= (1-input$conf/100), " is not", "is")
        c("Based on a confidence level of", input$conf,"% at a p-level of", round(abstats()$p.value,4),"the test result",results, " significant. The difference in conversion rate",results,"large enough to declare a significant difference.")
    })


})
