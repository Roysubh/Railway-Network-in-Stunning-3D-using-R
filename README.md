# Railway-Network-in-Stunning-3D-using-R

Overview:
This project demonstrates how to create a 3D visualization of Sri Lanka's railway network using Digital Elevation Model (DEM) data and OpenStreetMap (OSM) railway data.
We use R for spatial data processing and 3D rendering with the rayshader package.

Prerequisites:
R language with the following libraries:
pacman
sf
terra
elevatr
rayshader
scales
tidyverse

Steps:
1. Install and Load Libraries
2. Download and Prepare OSM Railway Data for Sri Lanka
        Download OSM railway shapefile for Sri Lanka from Geofabrik.
        Unzip and load the railway shapefile into R.
3. Get Country Boundary Data for Sri Lanka
        Download Sri Lanka's country boundary using the GADM dataset.
4. Download Digital Elevation Model (DEM) Data
        Download DEM data for Sri Lanka, clipped to the country boundary.
5. Reproject DEM Data (Optional)
        Reproject the DEM to Lambert Azimuthal Equal Area (LAEA) projection (optional).
6. Simplify and Filter Railway Data
        Filter the railway data to only keep relevant railway classes (e.g., "rail", "narrow_gauge").
        Simplify and reproject the railway shapefile.
7. Convert DEM Data to Matrix
        Convert the reprojected DEM raster to a matrix for rayshader visualization.
8. Render 3D Map and Overlay Railway Data
        Use rayshader to create a 3D visualization of the DEM.
        Overlay the railway data on top of the DEM.
9. Render and Save High-Quality Image
        Save the rendered 3D map as a high-quality image with HDR lighting.

onclusion:
This project demonstrates how to create a 3D visualization of the railway network in Sri Lanka using DEM and OSM data in R.
By following these steps, you can replicate similar visualizations for other regions by modifying the country boundary and OSM data.

Optional:
Download OSM Data from Geofabrik
You can download OSM data for other regions from Geofabrik.
Link:- "https://download.geofabrik.de/"
