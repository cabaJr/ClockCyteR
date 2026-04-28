# Annotate

R6 class object used for generating and storing plots and other
processed data. It is accessed internally to display data. Each top
level list contains a different type of plot. Sublists are organised to
store different plot versions. Functions for plotting (i.e.
plot_actogram, plot_DAct) get data from fct_R6_Custom_tables object and
generate a plot that is saved into the relative list. There should be a
method to pass plots to an external container based on the handler.

## Value

An Annotate object

## Public fields

- `store`:

  named list used as a keyed registry for all plot objects. Use
  store_obj(key, object) and retrieve_obj(key) to read and write. Keys
  used in the app: "ts_original", "ts_annotated", "periodogram_total",
  "periodogram_faceted", "periodogram_averaged", "period_barplot".

- `actTable`:

  Table containing data assembled using showData()

- `metaTable`:

  Table containing data assembled using showMeta() showMeta

## Methods

### Public methods

- [`Annotate$showMeta()`](#method-Annotate-showMeta)

- [`Annotate$showData()`](#method-Annotate-showData)

- [`Annotate$store_obj()`](#method-Annotate-store_obj)

- [`Annotate$retrieve_obj()`](#method-Annotate-retrieve_obj)

- [`Annotate$plot_Timeserie()`](#method-Annotate-plot_Timeserie)

- [`Annotate$plot_Timeserie_facet()`](#method-Annotate-plot_Timeserie_facet)

- [`Annotate$plot_periodogram()`](#method-Annotate-plot_periodogram)

- [`Annotate$plot_period_barplot()`](#method-Annotate-plot_period_barplot)

- [`Annotate$clone()`](#method-Annotate-clone)

------------------------------------------------------------------------

### Method `showMeta()`

function to create a table that arranges all the available metadata in a
table, and saves it in metaTable var

#### Usage

    Annotate$showMeta(env)

#### Arguments

- `env`:

  App_settings environment to access myCleanMice object

#### Returns

no return showdata

------------------------------------------------------------------------

### Method `showData()`

function to create a table that arranges activity data in a table, and
saves it in actTable var

#### Usage

    Annotate$showData(env, id, miceList)

#### Arguments

- `env`:

  App_settings environment to access myCleanMice object

- `id`:

  mouse Id value from the list of Ids or "All" to display all data

- `miceList`:

  list of all available mouse Ids

#### Returns

no return store_obj

------------------------------------------------------------------------

### Method `store_obj()`

a function to store objects inside the Annotate R6 obj

#### Usage

    Annotate$store_obj(key, object)

#### Arguments

- `key`:

  string to discriminate cases for storing file

- `object`:

  the object to be stored

#### Returns

no value returned retrieve_obj

------------------------------------------------------------------------

### Method `retrieve_obj()`

retrieve a stored object by key

#### Usage

    Annotate$retrieve_obj(key)

#### Arguments

- `key`:

  string key used when storing the object

#### Returns

the stored object, or NULL if the key does not exist plot_Timeserie

------------------------------------------------------------------------

### Method `plot_Timeserie()`

a function to create Timeseries plots

#### Usage

    Annotate$plot_Timeserie(
      datatable,
      value,
      env,
      tmin = 0,
      tmax = 999.81,
      data1 = TRUE,
      data2 = FALSE,
      data3 = FALSE,
      timeformat = "Hours"
    )

#### Arguments

- `datatable`:

  list contain all the data

- `value`:

  string to select data source: original, detrended or cleaned

- `env`:

  environment. App settings environment

- `tmin`:

  double. minimum time to be plotted

- `tmax`:

  double. maximum time to be plotted

- `data1`:

  Boolean. is dataset 1 present?

- `data2`:

  Boolean. is dataset 2 present?

- `data3`:

  Boolean. is dataset 3 present?

- `timeformat`:

  String. is the time in hours or posixt

#### Returns

a ggplot object plot_Timeserie_facet

------------------------------------------------------------------------

### Method `plot_Timeserie_facet()`

a function to create Timeseries plots stacked inside a grid

#### Usage

    Annotate$plot_Timeserie_facet(
      datalist,
      value,
      env,
      tmin = 0,
      tmax = 999.81,
      data1 = TRUE,
      data2 = FALSE,
      data3 = FALSE,
      timeformat = "Hours"
    )

#### Arguments

- `datalist`:

  list contain all the data

- `value`:

  string to select data source: original, detrended or cleaned

- `env`:

  environment. App settings environment

- `tmin`:

  double. minimum time to be plotted

- `tmax`:

  double. maximum time to be plotted

- `data1`:

  Boolean. is dataset 1 present?

- `data2`:

  Boolean. is dataset 2 present?

- `data3`:

  Boolean. is dataset 3 present?

- `timeformat`:

  String. is the time in hours or posixt

#### Returns

a ggplot object plot_periodogram

------------------------------------------------------------------------

### Method `plot_periodogram()`

Function to generate periodogram plots

#### Usage

    Annotate$plot_periodogram(
      method,
      plotType = c("Pertotal", "Perfaceted", "Peraveraged"),
      FunEnv
    )

#### Arguments

- `method`:

  function to use from zeitgebr::periodogram function

- `plotType`:

  the different type of plots to generate. default to total and faceted

- `FunEnv`:

  AppSettings environment

#### Returns

function returns internally, no direct output

plot_period_barplot

------------------------------------------------------------------------

### Method `plot_period_barplot()`

#### Usage

    Annotate$plot_period_barplot(method, FunEnv)

#### Arguments

- `method`:

  function used to run period analysis

- `FunEnv`:

  AppSettings environment

#### Returns

function returns internally

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    Annotate$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
