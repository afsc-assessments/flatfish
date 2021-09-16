
#detach("package:sa4all", unload = TRUE)
#remotes::install_github("afsc-assessments/sa4all")
library(sa4all)
# devtools::load_all("C:/Users/Chantel.Wetzel/Documents/GitHub/r4ss")

# Specify the directory for the document
setwd("C:/Assessments/2021/arrowtooth/doc")
base = "../runs/m0"

# Create the needed items to generate the "right" template that would be based on the inputs here:
draft(authors = c("Kalei Shotwell" ),
  			 species = "Arrowtooth flounder",
         latin = "Atheresthes stomias",
  			 coast = "Gulf of Alaska",
  			 type = c("ak"),
  			 create_dir = FALSE,
  			 edit = FALSE)

# Create a model Rdata object
# for SS3
# read_model( mod_loc = base, create_plots = FALSE, fecund_mult = 'mt', bub_scale = 4, save_loc = file.path(base, "tex_tables"), verbose = TRUE)
# load("00mod.Rdata")

# for bespoke flatfish model...
# to come

if(file.exists("_main.Rmd")){ file.remove("_main.Rmd") }
# Render the pdf
bookdown::render_book("00a.Rmd", clean=FALSE, output_dir = getwd())

# Use to only render a specific section which can be quicker
bookdown::preview_chapter("01executive.Rmd", preview = TRUE, clean = FALSE)