# Package index

## All functions

- [`Annotate`](https://cabajr.github.io/ClockCyteR/reference/Annotate.md)
  : Annotate
- [`load_data()`](https://cabajr.github.io/ClockCyteR/reference/load_data.md)
  : load_data
- [`manual_for_app_dev`](https://cabajr.github.io/ClockCyteR/reference/manual_for_app_dev.md)
  : NAMING CONVENTION Functions camelCase R6 objects Reverse camelCase
  with snakes. (confusing enough?) examples are: Custom_tables,
  App_settings, Annotate, R6_raw_data Modules Module names are written
  in snake_case, and they are used in: - app_ui.R file in tabItem
  function after the tabName arg, followed by "\_ui" - in app_server.R
  file in the server logic when importing the returned values Menu items
  Menu items names are spelled with PascalCase, and are used in:
  App_ui.R in the sidebarMenu function App_ui.R in the dashboardBody
  function app_server.R in render_tabItem(), in the tabname arg in each
  module when populating the list to be returned. The list itself is
  named with snake_case as it is referred to the module it its related
  to
- [`overwrite_vessel()`](https://cabajr.github.io/ClockCyteR/reference/overwrite_vessel.md)
  : overwrite_vessel
- [`run_app()`](https://cabajr.github.io/ClockCyteR/reference/run_app.md)
  : Run the Shiny Application
