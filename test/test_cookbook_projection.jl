using FactCheck
import ArchGDAL; const AG = ArchGDAL

facts("Reproject a Geometry") do
    println("Method 1")
    source = AG.unsafe_fromEPSG(2927); target = AG.unsafe_fromEPSG(4326)
        transform = AG.unsafe_createcoordtrans(source, target)
            point = AG.unsafe_fromWKT("POINT (1120351.57 741921.42)")
                println("Before: $(AG.toWKT(point))")
                AG.transform!(point, transform)
                println("After: $(AG.toWKT(point))")
    AG.destroy(point); AG.destroy(transform);
    AG.destroy(target); AG.destroy(source)

    println("Method 2")
    AG.fromEPSG(2927) do source; AG.fromEPSG(4326) do target
        AG.createcoordtrans(source, target) do transform
            AG.fromWKT("POINT (1120351.57 741921.42)") do point
                println("Before: $(AG.toWKT(point))")
                AG.transform!(point, transform)
                println("After: $(AG.toWKT(point))")
    end end end end
end

facts("Get Projection") do
    AG.registerdrivers() do
        AG.read("ospy/data1/sites.shp") do dataset
            layer = AG.borrow_getlayer(dataset, 0)
            spatialref = AG.borrow_getspatialref(layer)
            println(AG.toWKT(spatialref))
            println(AG.toWKT(spatialref, false))
            println(AG.toWKT(spatialref, true))
            println(AG.toProj4(spatialref))
            println(AG.toXML(spatialref))
            println(AG.toMICoordSys(spatialref))
            AG.nextfeature(layer) do feature
                feature |>
                    AG.borrow_getgeom |>
                    AG.borrow_getspatialref |>
                    AG.toWKT |>
                    println
            end
        end
    end

    AG.fromEPSG(26912) do spatialref
        println("before (Proj4): $(AG.toProj4(spatialref))")
        println("before (WKT): $(AG.toWKT(spatialref))")
        AG.morphtoESRI!(spatialref)
        println("after (Proj4): $(AG.toProj4(spatialref))")
        println("after: $(AG.toWKT(spatialref))")
    end
end