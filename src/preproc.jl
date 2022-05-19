module preproc

import CSV
using DataFramesMeta
using DataFrames

using Octo.Adapters.PostgreSQL
import LibPQ
using Term

# Define schemas
struct Aerodromo end
struct Reserva end
struct Ruta end
struct Tripulacion end
struct Vuelo end
struct Aerolinea end
struct Costo end
struct PuntoRuta end
struct Pasajero end
struct Piloto end
struct Avion end
struct Ciudad end
struct Pais end
struct Ticket end

function drop_tables()
    Repo.execute(
        raw"""
        drop table if exists aerolinea cascade;
        drop table if exists tripulacion cascade;
        drop table if exists vuelo cascade;
        drop table if exists tripulacion_vuelo cascade;
        drop table if exists aerodromo cascade;
        drop table if exists ciudad cascade;
        drop table if exists punto_ruta cascade;
        drop table if exists pasajero cascade;
        drop table if exists reserva cascade;
        drop table if exists ticket cascade;
        drop table if exists costo cascade;
        drop table if exists avion cascade;
        drop table if exists ruta cascade;
        drop table if exists pais cascade;
        drop table if exists piloto cascade;
        """
    )
end

function load_tables()
    open("data/tables.sql") do tables
        tables_query = read(tables, String)
        Repo.execute(tables_query)
    end
end

function main()
    # Connect to database
    Repo.debug_sql()
    Repo.connect(
        adapter=Octo.Adapters.PostgreSQL,
        host="localhost",
        user="grupo27",
        dbname="grupo27",
        password="elcañete123"
    )

    # Create tables
    # Load SQL from file
    try
        load_tables()
    catch e
        if e isa LibPQ.Errors.DuplicateTable
            drop_tables()
            @warn "Dropped all tables"
            load_tables()
        else
            error(e)
        end
    end

    # Import CSVs as DataFrames
    aerodromos = CSV.read("data/aerodromos.csv", DataFrame)
    reservas = CSV.read("data/reservasV2.csv", DataFrame)
    rutas = CSV.read("data/rutas.csv", DataFrame)
    trabajadores = CSV.read("data/trabajadores.csv", DataFrame)
    vuelos = CSV.read("data/vuelos.csv", DataFrame)

    # Aerodromos (y ciudades y paises)
    ciudades = Dict()
    paises = Dict()

    for aerodromo in eachrow(aerodromos)
        if aerodromo.nombre_ciudad ∉ keys(ciudades)
            if ! aerodromo.nombre_pais in paises
                paises[aerodromo.nombre_pais] = true
            end
            Repo.insert!(Ciudad, (
                nombre=aerodromo.nombre_ciudad,
                pais=aerodromo.nombre_pais
            ))
        end
        Repo.insert!(Aerodromo, (
            id = aerodromo.aerodromo_id,
            nombre = aerodromo.nombre,
            icao = aerodromo.codigo_icao,
            iata = aerodromo.codigo_iata,
            posicion = (aerodromo.latitud, aerodromo.longitud)
        ))
    end
end

end # module

preproc.main()