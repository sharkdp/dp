rm *.geojson
for file in *.gpx; do
    ogr2ogr -f GeoJSON ${file/gpx/geojson} $file tracks
done
