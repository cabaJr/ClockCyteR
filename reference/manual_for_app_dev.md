# NAMING CONVENTION Functions camelCase R6 objects Reverse camelCase with snakes. (confusing enough?) examples are: Custom_tables, App_settings, Annotate, R6_raw_data Modules Module names are written in snake_case, and they are used in: - app_ui.R file in tabItem function after the tabName arg, followed by "\_ui" - in app_server.R file in the server logic when importing the returned values Menu items Menu items names are spelled with PascalCase, and are used in: App_ui.R in the sidebarMenu function App_ui.R in the dashboardBody function app_server.R in render_tabItem(), in the tabname arg in each module when populating the list to be returned. The list itself is named with snake_case as it is referred to the module it its related to

How to return values from each module to the main app logic: Inside each
module 1. create a variable containing a NULL reactiveValue for each
value to return toReturn = reactiveValues(example = NULL) 2. populate a
mod_out list with all the reactiveValues created mod1_out \<-
list(example = toReturn\$example) 3. return the mod1_out variable In the
app_server.R fie 1. import the returned object, including the
App_settings environment mod1_out \<- mod_mod1_server("mod1_1", env =
App_settings)

## Details

TEMPLATE - to copy and paste in your module upon creation
