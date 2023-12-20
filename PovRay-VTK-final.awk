#!/usr/bin/awk -f

BEGIN {
    FS = "[<>]";
    OFS = " ";
    triangleCount = 0;
    vertices = "";
    triangles = "";
}

/^#/ || NF == 0 {
    next;
}
#check mesh
/^mesh/ {
    while (getline) {
    #parse triangle points 
        if ($0 ~ /triangle/) {
            triangleCount++;
            for (i = 2; i <= NF; i++) {
                if ($i ~ /-?[0-9]+,[[:space:]]*-?[0-9]+,[[:space:]]*-?[0-9]+/) {
                    split($i, coords, ",");
                    vertices = vertices (coords[1]+0) OFS (coords[2]+0) OFS (coords[3]+0) "\n";
                    triangles = triangles "3" OFS ((triangleCount-1) * 3) OFS ((triangleCount-1) * 3 + 1) OFS ((triangleCount-1) * 3 + 2) "\n";
                }
            }
        }
        if ($0 ~ /^}$/) {
            break;
        }
    }
}
END {
    if (triangleCount == 0) {
        print "Input file error " > "/dev/stderr";
        exit 1;
    }

    # Output the converted file
    print "vtk DataFile Version 2.0"
    print "ASCII"
    print "DATASET UNSTRUCTURED_GRID";
    print "POINTS " (triangleCount * 3) " float";
    print vertices;
    print "CELLS " triangleCount " " (triangleCount * 4);
    print triangles;
    print "CELL_TYPES " triangleCount;
    for (i = 0; i < triangleCount; i++) {
        print "5";
    }
}