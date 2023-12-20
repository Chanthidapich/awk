#!/bin/gawk -f

BEGIN {
  # Set the output file name
  outputFileName = "output.mesh"

  # Initialize variables
  numPoints = 0
  numFacets = 0
  numHoles = 0
  numRegions = 0

  # Set the default dimension
  dimension = 3

  # Set the default attributes and boundary markers
  numAttributes = 0
  numBoundaryMarkers = 0

  # Initialize arrays
  points = ""
  facets = ""
  holes = ""
  regions = ""
}

/^# Part 1 - node list$/ {
  getline
  split($0, nodeInfo)
  numPoints = nodeInfo[1]
  dimension = nodeInfo[2]
  numAttributes = nodeInfo[3]
  numBoundaryMarkers = nodeInfo[4]

  # Read node coordinates
  for (i = 1; i <= numPoints; i++) {
    getline
    split($0, node)
    points = points node[2] " " node[3] " " node[4] "\n"
  }
}

/^# Part 2 - facet list$/ {
  getline
  split($0, facetInfo)
  numFacets = facetInfo[1]

  # Read facet vertices
  for (i = 1; i <= numFacets * 2; i++) {
    getline
    split($0, facet)
    numPolygons = facet[1]

    # Skip lines with only one value
    if (numPolygons > 1) {
      facets = facets numPolygons

      # Read polygons
      for (j = 2; j < 2 + numPolygons; j++) {
        facets = facets " " facet[j]
      }

      # Read holes
      numHoles = facet[numPolygons + 2]
      if (numHoles > 0) {
        facets = facets " " numHoles

        for (k = numPolygons + 3; k <= numPolygons + 2 + numHoles; k++) {
          getline
          split($0, hole)
          holes = holes hole[2] " " hole[3] " " hole[4] "\n"
        }
      }

      facets = facets "\n"
    }
  }
}

/^# Part 3 - hole list$/ {
  getline
  numHoles = $0

  # Read hole coordinates
  for (i = 1; i <= numHoles; i++) {
    getline
    split($0, hole)
    holes = holes hole[2] " " hole[3] " " hole[4] "\n"
  }
}

/^# Part 4 - region attributes list$/ {
  getline
  numRegions = $0

  # Read region attributes
  for (i = 1; i <= numRegions; i++) {
    getline
    split($0, region)
    regions = regions region[2] " " region[3] " " region[4] " " region[5] " " region[6] "\n"
  }
}

END {
  # Open the output file
  output = outputFileName
  print "MeshVersionFormatted 2" > output
  print "Dimension", dimension >> output
  print "" >> output

  # Write vertices
  print "Vertices" >> output
  print numPoints >> output
  print points >> output
  print "" >> output

  # Write triangles
  print "Triangles" >> output
  print numFacets >> output
  print facets >> output
  print "" >> output

  # Write holes
  if (numHoles > 0) {
    print "Holes" >> output
    print numHoles >> output
    print holes >> output
    print "" >> output
  }

  # Write region attributes (optional)
  if (numRegions > 0) {
    print "RegionAttributes" >> output
    print numRegions >> output
    print regions >> output
    print "" >> output
  }

  
  # Close the output file
  close(output)

  print "Conversion completed"
}
