library(tidyverse)
library(tidygraph)   # for tbl_graph
library(igraph)      # network viz
library(ggraph)      # network viz
library(visNetwork)  # support interactivity
library(shiny)

# Load Data ----
# Nodes 
gastech_employees <- read_rds("data/gastech_employees.rds") %>% 
    mutate(title = paste(label, CurrentEmploymentTitle,' ')) %>%
    rename(group = CurrentEmploymentType,
           citizenship = CitizenshipCountry) %>% 
    select(id, label, group, title, citizenship)

# Edges 
gastech_emails <- read_rds("data/gastech_emails.rds")

gastech_emails_count <- gastech_emails %>% 
    group_by(Subject) %>%
    summarize(n = n()) %>%
    arrange(desc(n)) %>% 
    rowid_to_column("sort") 


gastech_edges <- gastech_emails %>% 
    group_by(source, target, Subject) %>% 
    summarize(weight=n()) %>%
    filter(weight>1) %>%
    ungroup() %>% 
    left_join(gastech_emails_count %>% select(Subject, sort)) %>%
    mutate(from = source, to = target) %>% 
    rowid_to_column("id") %>%
    arrange(sort)

# UI----
ui <- fluidPage(
    sidebarLayout(
        sidebarPanel(
            selectInput(
                inputId='email_header_select', 
                label = "Email Header", 
                choices = gastech_edges$Subject, 
                multiple=FALSE
            )
        ),
        mainPanel(visNetworkOutput("email_network_select"))
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
    
    output$email_network_select <- renderVisNetwork({
        
        selected_edges <- gastech_edges %>%
            filter(Subject %in% input$email_header_select)
        
        visNetwork(gastech_employees, selected_edges, width = "100%", height = '100%') %>%
            visIgraphLayout(layout = "layout_with_fr") %>%
            visLegend() %>%
            visEdges(smooth = FALSE, arrows = 'to') %>%
            visLayout(randomSeed = 123)
    })
    
    
}

# Run the application 
shinyApp(ui = ui, server = server)
