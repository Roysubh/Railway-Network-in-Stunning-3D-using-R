# 1. LIBRARIES

install.packages("pacman")
pacman::p_load(
    geodata,
    sf,
    elevatr,
    terra,
    tidyverse,
    rayshader,
    scales
)

# 2. OSM RAILWAY DATA FOR SRI LANKA

# Set up working directory for Sri Lanka OSM data
main_path <- getwd()
srilanka_dir <- "srilanka_osm"
dir.create(srilanka_dir)
out_dir_srilanka <- file.path(main_path, srilanka_dir)
setwd(out_dir_srilanka)
getwd()

# Download OSM railway data for Sri Lanka
options(timeout = 99999)
url <- "https://download.geofabrik.de/asia/sri-lanka-latest-free.shp.zip"  # Sri Lanka OSM railway data URL
destfile <- basename(url)

download.file(
    url = url,
    destfile = destfile,
    mode = "wb"
)

# Unzip downloaded file to extract railway shapefile
zip_file <- list.files()
zip_name <- grep(
    "railways",
    unzip(
        destfile,
        list = TRUE
    )$Name,
    ignore.case = TRUE,
    value = TRUE
)

unzip(
    destfile,
    files = zip_name,
    exdir = out_dir_srilanka,
    overwrite = TRUE
)

list.files()  # Check the extracted files

# Load the railway shapefile
rail_sf <- sf::st_read("gis_osm_railways_free_1.shp")

# 3. COUNTRY BOUNDARIES FOR SRI LANKA

# Download Sri Lanka country boundary using GADM data
country_sf <- geodata::gadm(
    country = "LKA",  # ISO code for Sri Lanka
    level = 0,
    path = getwd()
) |>
sf::st_as_sf()

# 4. DIGITAL ELEVATION MODEL

# Get elevation data for Sri Lanka using the GADM country boundaries
elev <- elevatr::get_elev_raster(
    locations = country_sf,
    z = 8,
    clip = "locations"
)

# Project DEM into WGS 84 (EPSG:4326) projection
crs <- "EPSG:4326"

elev_wgs84 <- elev |>
    terra::rast() |>
    terra::project(crs)

# Convert raster to matrix for rayshader visualization
elmat <- elev_wgs84 |>
    rayshader::raster_to_matrix()

# 5. SIMPLIFY AND TRANSFORM RAILWAYS

# Filter and simplify railway lines to only keep important classes
country_rail <- rail_sf |>
    dplyr::filter(
        fclass %in% c("rail", "narrow_gauge")
    ) |>
    sf::st_intersection(country_sf) |>
    sf::st_simplify(
        preserveTopology = TRUE,
        dTolerance = 1000
    ) |>
    sf::st_transform(crs = crs)

# 6. RENDER OBJECT AND SCENE SETUP
#-------------------------------

# Download HDR environment lighting file for high-quality rendering
hdr_url <- "https://dl.polyhaven.org/file/ph-assets/HDRIs/hdr/4k/photo_studio_loft_hall_4k.hdr"
hdri_file <- basename(hdr_url)

download.file(
    url = hdr_url,
    destfile = hdri_file,
    mode = "wb"
)

# Define a custom color palette for elevation shading
elevation_colors <- c("blue", "green", "yellow", "brown", "white")

# Display the color palette to see the transition
scales::show_col(elevation_colors, ncol = 5, labels = TRUE)

# 7. RENDER 3D SCENE WITH OVERLAY AND SAVE IMAGE
#-----------------------------------------------

# Adjust zscale, line color, and line width for better visibility
elmat |>
    rayshader::height_shade(
        texture = colorRampPalette(elevation_colors)(128)
    ) |>
    rayshader::add_overlay(
        rayshader::generate_line_overlay(
            geometry = country_rail,
            extent = elev_wgs84,
            heightmap = elmat,
            color = "black",  # Set railway line color to red for better contrast
            linewidth = 10  # Increase line width for better visibility
        ),
        alphalayer = 1
    ) |>
    rayshader::plot_3d(
        elmat,
        zscale = 8,  # Reduce zscale to flatten the terrain for better overlay visibility
        solid = FALSE,
        shadow = TRUE,
        shadow_darkness = 0.7,  # Adjust shadow darkness for clarity
        background = "white",
        windowsize = c(800, 600),
        zoom = 0.55,
        phi = 89,
        theta = 0
    )

# Specify the output image file name
img_name <- "3d-railway-map-srilanka.png"

# Render high-quality image with HDR lighting and save
rayshader::render_highquality(
    filename = img_name,
    preview = TRUE,
    interactive = FALSE,
    light = TRUE,
    environment_light = hdri_file,
    intensity_env = 0.6,
    parallel = TRUE,
    line_radius = 5,
    width = 400 * 3,
    height = 300 * 3
)
