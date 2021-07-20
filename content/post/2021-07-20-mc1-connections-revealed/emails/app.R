library(tidyverse)
library(tidygraph)   # for tbl_graph
library(igraph)      # network viz
library(ggraph)      # network viz
library(visNetwork)  # support interactivity
library(shiny)

# Load Data ----
# Nodes 
gastech_employees <- read_rds("data/gastech_employees.rds") %>% 
    rename(department = CurrentEmploymentType, 
           title = CurrentEmploymentTitle, 
           citizenship = CitizenshipCountry) %>% 
    select(id, label, department, title, citizenship)
gastech_employees 

# Edges 
gastech_emails <- read_rds("data/gastech_emails.rds")
gastech_emails

gastech_edges <- gastech_emails %>% 
    group_by(source, target) %>% 
    summarize(weight=n()) %>%
    filter(weight>1) %>%
    ungroup() %>% 
    mutate(from = source, to = target)

# UI----
ui <- fluidPage()

# Define server logic required to draw a histogram
server <- function(input, output) {}

# Run the application 
shinyApp(ui = ui, server = server)
