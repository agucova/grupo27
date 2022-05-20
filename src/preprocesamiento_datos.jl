### A Pluto.jl notebook ###
# v0.19.3

using Markdown
using InteractiveUtils

# ╔═╡ 8a224b4b-f755-40b2-8bed-fad5bb58f785
using DataFramesMeta

# ╔═╡ 9f130e24-32de-4a63-b8d9-202b5456ba58
using PlutoUI

# ╔═╡ 07ec0a82-f0b7-4788-ae16-8d6ad0a2abf9
using Dates

# ╔═╡ 3a241435-ea7d-4f24-982d-0ceec9218318
TableOfContents(title="📚 Tabla de Contenidos", aside=true)

# ╔═╡ 58133e6a-6038-446b-ab68-701cfd28ee38
md"""
# Preprocesamiento de Datos - BBDD
## Dependencias
"""

# ╔═╡ 36fd3665-c41f-4142-bfe2-260bc7bf000b
import CSV

# ╔═╡ c04cb8ca-0856-49cf-b8a4-434e9615466c
md"""## Importación de Datos"""

# ╔═╡ b93b96fc-08ae-457c-b27a-13cc95b9e0c8
tabla_aerodromos = CSV.read("../data/aerodromos.csv", DataFrame)

# ╔═╡ d2bae887-ec35-45a5-93b8-9cfe5641e8bd
tabla_rutas = CSV.read("../data/rutas.csv", DataFrame)

# ╔═╡ 7cfedd43-4a2c-49bd-93a0-9e066f626f51
md"""Debemos usar un formato específico para que CSV reconozca las fechas en el CSV:"""

# ╔═╡ 50fc9dba-1026-4b57-9eba-a056fa05d1b9
tabla_trabajadores = CSV.read("../data/trabajadores.csv", DataFrame, dateformat=DateFormat("d-m-y"))

# ╔═╡ 21d4a33b-2c6e-4f0a-9ff1-361efa66dd77
md"""Para la tabla reserva debemos también ajustar el formato de fecha:"""

# ╔═╡ 11e43a42-0e5b-4aea-956d-fc714326ace3
tabla_reservas = CSV.read("../data/reservasV2.csv", DataFrame, dateformat=DateFormat("d-m-y"))

# ╔═╡ d5b601cd-756d-40f8-bf53-9d2a19f3d5e9
md"""El archivo de vuelos usa un formato de fecha distinto a reservas y trabajadores, y aunque incluye horas, no son horas *timezone aware*, por lo que asumimos que se encuentran en UTC."""

# ╔═╡ e2f0dc89-7385-40bf-a76c-b5639f477011
tabla_vuelos = CSV.read("../data/vuelos.csv", DataFrame, dateformat=DateFormat("y-m-d H:M:S"))

# ╔═╡ 3c3804dc-ea57-4458-a83d-2b250b80427d
md"""## Procesamiento de Datos
### Aerodromos
"""

# ╔═╡ 8460f7dd-de9a-4ae3-acf7-3fc63ba09cff
md"""Definimos las estructuras de datos que vamos a usar:"""

# ╔═╡ 7ee22f95-5af8-44e9-983a-a62cffdf00c5
struct Pais
	id::Int64
	nombre::String
end

# ╔═╡ c04dd998-bf12-4170-8166-93f1e6dac518
struct Ciudad
	id::Int64
	nombre::String
	id_pais::Int64
end

# ╔═╡ 2900ed94-edf2-49db-9f3f-ade7dbe7f34e
struct Aerodromo
	id::Int64
	nombre::String
	icao::String
	iata::String
	posicion::Tuple{Float64, Float64}
	id_ciudad::Int64
end

# ╔═╡ f69e5c6b-85af-49e8-afde-6865d7baba5d
md"""Primero identificamos los paises y sus ciudades respectivas en el diccionario `paises_ciudades`. (En Julia `a ∉ b` es equivalente a `a not in b` en Python)."""

# ╔═╡ ff9ceb7c-1d42-45c9-a65d-8af8b40e0aec
begin
	paises_ciudades = Dict()
	for aerodromo in eachrow(tabla_aerodromos)
		# Handle the saving of new countries and their cities
		if aerodromo.nombre_pais ∉ keys(paises_ciudades)
			# Create new country
			paises_ciudades[aerodromo.nombre_pais] = [aerodromo.nombre_ciudad]
		elseif aerodromo.nombre_ciudad ∉ paises_ciudades[aerodromo.nombre_pais]
			# Add a city to an existing country
			push!(paises_ciudades[aerodromo.nombre_pais], aerodromo.nombre_ciudad)
		end
	end
end

# ╔═╡ 8f0a8fff-2634-487c-8063-279f5c1200f7
paises_ciudades

# ╔═╡ 1ed2c24e-3c71-4e2c-b7b5-eafd45aa4625
begin
	paises = Vector{Pais}()
	ciudades = Vector{Ciudad}()
	
	for (id_pais, (pais, ciudades_en_pais)) in enumerate(pairs(paises_ciudades))
		# Add the country
		push!(paises, Pais(
			id_pais,
			pais		
		))
		for (id_ciudad, ciudad) in enumerate(ciudades_en_pais)
			push!(ciudades, Ciudad(
				# We determine the ID sequentially
				length(ciudades) + 1,
				ciudad,
				id_pais
			))
		end
	end
end

# ╔═╡ 1d36072c-6981-4b99-a864-f1239d717050
paises

# ╔═╡ 29c14d56-bfef-4f25-ba17-318a644da2f1
ciudades

# ╔═╡ 7a815ed6-a6fb-4971-b84b-8c566dff6a48
md"""Verificamos que no hayan paises o ciudades duplicadas:"""

# ╔═╡ 1f3e85c1-9d45-4ef5-b218-c9df553c8233
nombre_paises = [pais.nombre for pais in paises]

# ╔═╡ a26adba2-3d29-4a7a-9752-1396fe4e4efc
nombre_ciudades = [ciudad.nombre for ciudad in ciudades]

# ╔═╡ 360bf1d5-62e9-405d-8c7c-375b73dfe720
@assert unique(nombre_paises) == nombre_paises

# ╔═╡ d073c943-4e4e-4bb3-b667-806bc1147d21
@assert unique(nombre_ciudades) == nombre_ciudades

# ╔═╡ 32fc00bd-63f8-4c41-a9f4-de79f95651b3
md"""Ahora pasamos a crear los aerodromos"""

# ╔═╡ 42c80dd1-011f-49f5-a2e8-da1fd1042724
begin
	aerodromos = Vector{Aerodromo}()
	for aerodromo in eachrow(tabla_aerodromos)
		# Con esto asumimos que no hay nombres repetidos de ciudades
		# Lo que no necesariamente es realista, pero es verdadero en este dataset
		id_ciudad = findfirst(c -> c.nombre == aerodromo.nombre_ciudad, ciudades)
		push!(aerodromos, Aerodromo(
			# We don't need to generate IDs like in ciudad or pais
			# Because they're already given in the table
			aerodromo.aerodromo_id,
			aerodromo.nombre,
			aerodromo.codigo_ICAO,
			aerodromo.codigo_IATA,
			# We use (lat, long) per ISO6709
			(aerodromo.latitud, aerodromo.longitud),
			id_ciudad
		))
	end
	aerodromos
end

# ╔═╡ 5230fa1e-7ce7-4c54-9633-5441a410d767
md"""Verificamos que no hayan aerodromos duplicados:"""

# ╔═╡ ae712ff8-6e16-4487-9fb7-9d105ef05dd9
@assert unique(aerodromos) == aerodromos

# ╔═╡ ca9eceb6-f46a-4389-a0a3-d0580242a537
md"""### Rutas"""

# ╔═╡ 21c612b7-d964-42ff-b449-d9b777fcb099
struct Ruta
	id::Int64
	nombre::String
end

# ╔═╡ fee7e0dd-2cde-4a21-87ae-b2248ff6efe4
struct PuntoRuta
	id::Int64
	id_ruta::Int64
	indice::Int64
	nombre::String
	posicion::Tuple{Float64, Float64}
end

# ╔═╡ c64c4d82-2472-42b3-bffa-e5f407c75683
tabla_rutas

# ╔═╡ c475bef5-4e54-4de5-9721-d7237b697fc1
id_rutas = unique(sort(tabla_rutas.ruta_id))

# ╔═╡ 472293ba-9421-4371-8096-9ade3f04b0dd
begin
	rutas = Vector{Ruta}()
	puntos_ruta = Vector{PuntoRuta}()
	for id_ruta in id_rutas
		# Find all points with the given route ID
		point_indices = findall(r -> r.ruta_id == id_ruta, eachrow(tabla_rutas))
		points = [tabla_rutas[i, :] for i in point_indices]
		# Sort those points by cardinality
		sort!(points, by = p -> p.cardinalidad)
		# Create route
		push!(rutas, Ruta(
			id_ruta,
			points[1].nombre_ruta
		))
		# Create the points
		for (indice, point) in enumerate(points)
			push!(puntos_ruta, PuntoRuta(
				# Assing sequential IDs
				length(puntos_ruta) + 1,
				id_ruta,
				# Note we use indices starting in 1
				# Unlike "cardinality" in the given table
				indice,
				point.nombre_punto,
				# ISO 6709 again
				(point.latitud, point.longitud)
			))
		end
	end
end

# ╔═╡ 00826089-a9eb-491f-9625-4e71b7ce8801
rutas

# ╔═╡ 81c35341-002d-45c5-ae4f-16051d1d8297
puntos_ruta

# ╔═╡ 4405fe29-51d0-4bc8-aef6-bf1245ac9f16
md"""Verificamos que no hay rutas duplicadas:"""

# ╔═╡ 072f0721-5d0e-406e-82db-545ce1db11ed
nombres_ruta = [ruta.nombre for ruta in rutas]

# ╔═╡ 58aab315-af4c-4329-a94d-1d143d93c518
@assert unique(nombres_ruta) == nombres_ruta "Las rutas debiesen ser únicas"

# ╔═╡ be69af11-b8c3-40ad-b7e1-2ed0dd6432a0
# ╠═╡ disabled = true
#=╠═╡
[puntos_ruta[i, :] for i in findall(p -> p.id_ruta == 14, puntos_ruta)]

  ╠═╡ =#

# ╔═╡ 22ef1f47-1ced-4f4b-ac60-ce4eb6996eb8
md"""### Trabajadores"""

# ╔═╡ e2ad59e3-481e-43bb-8c28-463ceeacc2bf
md"""Por ahora nos limitamos a la info de la tripulación, sin vincular los datos con vuelos todavía."""

# ╔═╡ 22617b8c-d588-4f6a-86bd-5e84074e0aef
struct Tripulacion
	id::Int64
	nombre::String
	fecha_nacimiento::Date
	pasaporte::String
end

# ╔═╡ e8b36ab8-7e37-4480-a577-3012b91f7459
struct Piloto
	id::Int64
	nombre::String
	fecha_nacimiento::Date
	pasaporte::String
end

# ╔═╡ be0be98f-0b55-4703-a7fb-d1ba82ee0f45
struct Licencia
	id::Int64
	id_piloto::Int64
end

# ╔═╡ 8bce8540-a97a-431a-80c2-40892fbc85a1
struct Maneja
	id_vuelo::Int64
	id_piloto::Int64
	id_licencia::Int64
	rol::String
end

# ╔═╡ 4719aca1-3887-4474-8e5a-0260d40d516e
tabla_trabajadores

# ╔═╡ 929b7157-8038-47c2-9669-632561ce7fe1
md"""Comprobamos que efectivamente las licencia solo estén asociadas a un trabajador:"""

# ╔═╡ fd893daa-efa0-411e-9903-8ec82392b2d5
begin
	licencias_personas = Dict()
	for trabajador in eachrow(tabla_trabajadores)
		lic = trabajador.licencia_actual_id
		if ! ismissing(lic)
			if lic ∉ keys(licencias_personas)
				licencias_personas[lic] = Set(trabajador.trabajador_id)
			else
				push!(licencias_personas[lic], trabajador.trabajador_id)
			end
		end
	end
	licencias_personas
end

# ╔═╡ 7b318091-534b-4173-88bf-d82779a45ed9
@assert all(p -> length(p.second) == 1, licencias_personas) "Hay licencias asociadas a múltiples trabajadores"

# ╔═╡ 80e237dd-a910-48f4-96eb-bb9a58998220
md"""Y ahora empezamos a rellenar con las estructuras de datos"""

# ╔═╡ a242d04e-6898-46b6-bfe3-f3635300ab81
ispilot(t) = ! ismissing(t.rol) && t.rol ∈ ["Piloto", "Copiloto"]

# ╔═╡ 91b131ce-fe5c-4182-80bd-c76ae28a5230
tripulacion_from_t(t) = Tripulacion(
	t.trabajador_id,
	t.nombre,
	t.fecha_nacimiento,
	t.pasaporte
)

# ╔═╡ eea80bb0-9562-4795-9dda-0751f15a6e73
piloto_from_t(t) = Piloto(
	t.trabajador_id,
	t.nombre,
	t.fecha_nacimiento,
	t.pasaporte
)

# ╔═╡ a32074ef-c685-4682-935d-688b15f4ea7b
licencia_from_t(t) = Licencia(
	t.licencia_actual_id,
	t.trabajador_id
)

# ╔═╡ 5624e59b-5360-41f6-be26-f45d340a5513
maneja_from_t(t) = Maneja(
	t.vuelo_id,
	t.trabajador_id,
	t.licencia_actual_id,
	t.rol
)

# ╔═╡ f6ed47b5-afae-443f-a00f-6874ce4f03d3
exists(f, c) = ! isnothing(findfirst(f, c))

# ╔═╡ a18a5446-c3e6-4bf5-b9fa-29473e75d53f
id_exists(c, id) = exists(x -> x.id == id, c)

# ╔═╡ cc58b6f5-c3df-4d54-82c4-b688841fdb24
begin
	tripulaciones = Tripulacion[]
	pilotos = Piloto[]
	licencias = Licencia[]
	manejas = Maneja[]

	for t in eachrow(tabla_trabajadores)
		if ! ispilot(t)
			# Flight crew
			if ! id_exists(tripulaciones, t.trabajador_id)
				push!(tripulaciones, tripulacion_from_t(t))
			end
		else
			# Pilots and copilots
			if ! id_exists(pilotos, t.trabajador_id)
				push!(pilotos, piloto_from_t(t))
			end
			if ! ismissing(t.licencia_actual_id)
				# Licenses
				if ! id_exists(licencias, t.licencia_actual_id)
					push!(licencias, licencia_from_t(t))
				end
				# Maneja
				push!(manejas, maneja_from_t(t))
			end
		end
	end
end

# ╔═╡ cc26848c-1e5e-4af7-8db8-c9b6a7939437
tripulaciones

# ╔═╡ 746b8029-b76f-44c1-a075-8dea9a4b58a0
licencias

# ╔═╡ 785849a5-6c29-4e6c-b077-64f06e57af24
manejas

# ╔═╡ 3701f6e7-8d36-4022-92e6-b75e62436c29
length(tripulaciones)

# ╔═╡ 41212a6a-dd84-46ef-b840-5dbeed851e4b
length(licencias)

# ╔═╡ 582878e1-2298-44b8-b836-3738671ec06d
length(manejas)

# ╔═╡ 8a7eee3a-78aa-40ca-aca6-5b6d63a8e045
md"""Revisamos que no hayan duplicaciones:"""

# ╔═╡ 4b2ba701-7f42-4b10-92f5-2e40bdab315d
@assert unique(tripulaciones) == tripulaciones "Las entradas de trip. deberían ser únicas"

# ╔═╡ 0977b4ed-845f-4501-9bde-05d1c7ff0602
@assert unique(licencias) == licencias "Las licencias deberían ser únicas."

# ╔═╡ 845361e9-c256-40ba-a7ed-a75ddf163b02
md"""### Aerolineas"""

# ╔═╡ d5c42dc3-1729-4f03-a7ca-10cefc617382
md"""Aquí tenemos que cruzar los datos en tanto rutas como trabajadores para asegurnanos de caracterizar bien todas las aerolíneas presentes."""

# ╔═╡ 2e6cb744-a504-4203-8c62-839b2d3864b2
md"""Una observación importante es que hay entradas en la tabla de trabajadores que no tienen registros de empleo, teniendo datos faltantes sobre compañías. Dado que en principio podrían estar simplemente "cesantes", los incluiremos de todas formas en la base de datos."""

# ╔═╡ 220f157d-1309-4f29-8bed-8646504f3d72
findall(t -> ismissing(t.codigo_compania), eachrow(tabla_trabajadores))

# ╔═╡ feffb922-d279-4c53-87f1-2db19d2ac697
md"""Dicho eso, procedemos a procesar los datos:"""

# ╔═╡ 9a50a7c2-c398-4eac-af89-a9a62a00e873
struct Aerolinea
	id::Int64
	nombre::String
	codigo::String
end

# ╔═╡ 0f428918-6733-42f7-b540-2e60ed5b4129
begin
	aerolineas = Vector{Aerolinea}()
	# Buscamos todos los códigos de aerolíneas en
	# las tablas de trabajadores y vuelos
	codigos_en_trabajadores = sort(filter(
		x -> ! ismissing(x), unique(tabla_trabajadores.codigo_compania)
	))
	codigos_en_vuelos = sort(unique(tabla_vuelos.codigo_compania))
	# En el mundo real esto no tiene por qué ser cierto,
	# Entendido que una aerolinea podria dejar de tener vuelos por un tiempo
	# O incluso podria dejar de tener empleados, aunque eso ya se escapa la modelación
	# permitida por el formato de datos entregado
	@assert codigos_en_vuelos == codigos_en_trabajadores

	for codigo in codigos_en_trabajadores
		# Find a sample row
		sample_id = findfirst(
			a -> a.codigo_compania == codigo, eachrow(tabla_trabajadores)
		)
		sample = tabla_trabajadores[sample_id, :]
		# Now add the airline
		push!(aerolineas, Aerolinea(
			# Generate a sequential ID
			length(aerolineas) + 1,
			# Get name from sample
			sample.nombre_compania,
			# Use the code we already have
			codigo
		))
	end
end

# ╔═╡ f2c19dfa-b360-487f-b3ae-0a453b3e7bbb
md"""Notoriamente, hay una aerolínea llamada `NO_COMPANY`:"""

# ╔═╡ 5265b537-ee35-4151-b2f9-251e65f9e1af
aerolineas

# ╔═╡ 1c4b7f07-15a5-4b70-bb6c-8aebfb1524b6
md"""Dado que esta si tiene vuelos y un código, asumiremos que constituye una aerolínea real, incluso si es un placeholder."""

# ╔═╡ b41d8f03-8dad-4e57-818c-25cb5cf46044
md"""Verificamos que no se repitan las aerolineas:"""

# ╔═╡ 6f06eac0-c8a2-458a-8573-d6718ed7db15
codigos_aerolineas = [aerolinea.codigo for aerolinea in aerolineas]

# ╔═╡ 600c127c-f395-4fef-8a7e-9464033701da
@assert unique(codigos_aerolineas) == codigos_aerolineas

# ╔═╡ 71cbde30-d2ae-4729-a499-69b842c7c138
md"""### Vuelos"""

# ╔═╡ 22ce3784-45a6-49bb-a643-5b25397c849c
struct Avion
	id::Int64
	nombre::String
	modelo::String
	peso::Float64
	codigo::String
end

# ╔═╡ 08948bf5-859b-49db-bef9-2aa47314273e
struct Vuelo
	id::Int64
	id_aerolinea::Int64
	id_origen::Int64
	id_destino::Int64
	id_avion::Int64
	id_ruta::Int64
	codigo::String
	fecha_salida::DateTime
	fecha_llegada::DateTime
	velocidad::Float64
	altitud::Float64
	estado::String
end

# ╔═╡ 93c50119-b5b3-4ac2-8013-107f0c5218a1
begin
	aviones = Vector{Avion}()
	aviones_ya_agregados = Vector{String}()
	for vuelo in eachrow(tabla_vuelos)
		if vuelo.codigo_aeronave ∉ aviones_ya_agregados
			push!(aviones, Avion(
				length(aviones) + 1,
				vuelo.nombre_aeronave,
				vuelo.modelo,
				vuelo.peso,
				vuelo.codigo_aeronave
			))
			push!(aviones_ya_agregados, vuelo.codigo_aeronave)
		end
	end
end

# ╔═╡ c29d6738-e582-4c87-862e-9d26cfc29a9a
function vuelo_from_v(v)
	id_aerolinea = findfirst(a -> a.codigo == v.codigo_compania, aerolineas)
	id_avion = findfirst(a -> a.codigo == v.codigo_aeronave, aviones)
	
	return Vuelo(
		v.vuelo_id,
		id_aerolinea,
		v.aerodromo_salida_id,
		v.aerodromo_llegada_id,
		id_avion,
		v.ruta_id,
		v.codigo_vuelo,
		v.fecha_salida,
		v.fecha_llegada,
		v.velocidad,
		v.altitud,
		lowercase(strip(v.estado))
	)
end

# ╔═╡ 74a4da92-c5c1-4e2e-8b8a-5c85b0299341
begin
	vuelos = Vector{Vuelo}()
	for v in eachrow(tabla_vuelos)
		push!(vuelos, vuelo_from_v(v))
	end
end

# ╔═╡ 21773789-5de7-4df3-b945-31f07fd0eb8e
vuelos

# ╔═╡ e843330f-f879-45f6-b1cd-3aeb4ca2518d
md"""### Reservas"""

# ╔═╡ 2a5851d0-cf78-4b1a-86d3-3a1859fcfe42
struct Pasajero
	id::Int64
	pasaporte::Union{String, Missing}
	nombre::String
	fecha_nacimiento::Date
	nacionalidad::String
end

# ╔═╡ f5f15f65-9cb1-46ec-b917-54a5e4d65db7
struct Reserva
	id::Int64
	codigo::String
	id_reservante::Int64
end

# ╔═╡ 68097a42-8513-4cd9-8159-1e3469294e05
struct Ticket
	id::Int64
	id_vuelo::Int64
	id_pasajero::Int64
	id_reserva::Int64
	asiento::Int64
	clase::String
	comida_y_maleta::Bool
end

# ╔═╡ 23a11ee0-8164-4143-a4ce-1d798c6fc87e
pasajero_from_t(t, id) = Pasajero(
	id,
	t.pasaporte_pasajero,
	t.nombre_pasajero,
	t.fecha_nacimiento_pasajero,
	lowercase(strip(t.nacionalidad_pasajero))
)

# ╔═╡ bc8a7eda-df0c-49f3-ac52-cec16f31771b
function find_pasajero(pasajeros, t)
	if ! ismissing(t.pasaporte_pasajero)
		for pasajero in pasajeros
			if pasajero.pasaporte == t.pasaporte_pasajero
				return pasajero
			end
		end
	elseif (! ismissing(t.nombre_pasajero)) && (! ismissing(t.fecha_nacimiento))
		for pasajero in pasajeros
			if (
				pasajero.nombre == t.nombre_pasajero &&
				pasajero.fecha_nacimiento == t.fecha_nacimiento_pasajero
			)
				return pasajero
			end
		end
	else
		return missing
	end
	return nothing
end

# ╔═╡ 66fd248c-1439-4ca9-9a35-f71a92e63760
function find_reservante(pasajeros, t)
	if ! ismissing(t.pasaporte_comprador)
		for pasajero in pasajeros
			if pasajero.pasaporte == t.pasaporte_comprador
				return pasajero
			end
		end
	else
		for pasajero in pasajeros
			if (
				pasajero.nombre == t.nombre_comprador &&
				pasajero.fecha_nacimiento == t.fecha_nacimiento_comprador
			)
				return pasajero
			end
		end

	end
	return nothing
end

# ╔═╡ 2e7d7d75-9ec8-474a-bb59-5b422e43c418
begin
	pasajeros = Pasajero[]
	reservas = Reserva[]
	tickets = Ticket[]
	
	for t in eachrow(tabla_reservas)
		# Pasajero
		pasajero = find_pasajero(pasajeros, t)
		reserva_unica = ismissing(pasajero)
		if reserva_unica
			pasajero = find_reservante(pasajeros, t)
		end
		if isnothing(pasajero) && (! reserva_unica)
			push!(pasajeros, pasajero_from_t(t, length(pasajeros) + 1))
		elseif isnothing(pasajero)
			push!(pasajeros, Pasajero(
				length(pasajeros) + 1,
				pasaporte_comprador,
				nombre_comprador,
				fecha_nacimiento_comprador,
				lowercase(strip(nacionalidad_comprador))
			))
		end
	end

	for t in eachrow(tabla_reservas)
		# Reserva
		reservante = find_reservante(pasajeros, t)
		if ! id_exists(reservas, t.reserva_id)
			push!(reservas, Reserva(
				t.reserva_id,
				t.codigo_reserva,
				reservante.id
			))
		end
		# Ticket
		pasajero = find_pasajero(pasajeros, t)
		reserva_unica = ismissing(pasajero)
		if reserva_unica
			pasajero = find_reservante(pasajeros, t)
		end
		if ! id_exists(tickets, t.numero_ticket)
			push!(tickets, Ticket(
				t.numero_ticket,
				t.vuelo_id,
				pasajero.id,
				t.reserva_id,
				t.numero_asiento,
				t.clase,
				t.comida_y_maleta == "VERDADERO"
			))
		end
	end
end

# ╔═╡ 0bacda4a-3395-4d35-8e4d-92bc3ca75b97
pasajeros

# ╔═╡ 80370f25-91fe-4cb6-9f85-e6e57064fe11
@assert unique(pasajeros) == pasajeros

# ╔═╡ 348fbb30-38d5-4f9a-a6c0-27b6e4bdf6ea
reservas

# ╔═╡ c4341df9-7387-4d98-9e4c-5c9c9a415579
@assert unique(reservas) == reservas

# ╔═╡ 47febd2f-cdda-4222-b74e-8c779d6e092e
tickets

# ╔═╡ 2dc50016-b862-4113-af43-d03e7bd7c157
@assert unique(tickets) == tickets

# ╔═╡ 9d28ee69-cfcd-4692-8a08-09f124f2c735
md"""## Exportación de datos"""

# ╔═╡ 7874ff3f-8dee-4a14-b658-7687b42297ed
paises |> CSV.write("../tablas/paises.csv")

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
CSV = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
DataFramesMeta = "1313f7d8-7da2-5740-9ea0-a2ca25f37964"
Dates = "ade2ca70-3891-5945-98fb-dc099432e06a"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
CSV = "~0.10.4"
DataFramesMeta = "~0.11.0"
PlutoUI = "~0.7.38"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.7.2"
manifest_format = "2.0"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "8eaf9f1b4921132a4cff3f36a1d9ba923b14a481"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.4"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.CSV]]
deps = ["CodecZlib", "Dates", "FilePathsBase", "InlineStrings", "Mmap", "Parsers", "PooledArrays", "SentinelArrays", "Tables", "Unicode", "WeakRefStrings"]
git-tree-sha1 = "873fb188a4b9d76549b81465b1f75c82aaf59238"
uuid = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
version = "0.10.4"

[[deps.Chain]]
git-tree-sha1 = "339237319ef4712e6e5df7758d0bccddf5c237d9"
uuid = "8be319e6-bccf-4806-a6f7-6fae938471bc"
version = "0.4.10"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "ded953804d019afa9a3f98981d99b33e3db7b6da"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "a985dc37e357a3b22b260a5def99f3530fb415d3"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.2"

[[deps.Compat]]
deps = ["Base64", "Dates", "DelimitedFiles", "Distributed", "InteractiveUtils", "LibGit2", "Libdl", "LinearAlgebra", "Markdown", "Mmap", "Pkg", "Printf", "REPL", "Random", "SHA", "Serialization", "SharedArrays", "Sockets", "SparseArrays", "Statistics", "Test", "UUIDs", "Unicode"]
git-tree-sha1 = "b153278a25dd42c65abbf4e62344f9d22e59191b"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "3.43.0"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"

[[deps.Crayons]]
git-tree-sha1 = "249fe38abf76d48563e2f4556bebd215aa317e15"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.1.1"

[[deps.DataAPI]]
git-tree-sha1 = "fb5f5316dd3fd4c5e7c30a24d50643b73e37cd40"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.10.0"

[[deps.DataFrames]]
deps = ["Compat", "DataAPI", "Future", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrettyTables", "Printf", "REPL", "Reexport", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "daa21eb85147f72e41f6352a57fccea377e310a9"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.3.4"

[[deps.DataFramesMeta]]
deps = ["Chain", "DataFrames", "MacroTools", "OrderedCollections", "Reexport"]
git-tree-sha1 = "f1d89a07475dc4b03c08543d1c6b4b2945f33eca"
uuid = "1313f7d8-7da2-5740-9ea0-a2ca25f37964"
version = "0.11.0"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "cc1a8e22627f33c789ab60b36a9132ac050bbf75"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.12"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[deps.Downloads]]
deps = ["ArgTools", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[deps.FilePathsBase]]
deps = ["Compat", "Dates", "Mmap", "Printf", "Test", "UUIDs"]
git-tree-sha1 = "129b104185df66e408edd6625d480b7f9e9823a0"
uuid = "48062228-2e41-5def-b9a4-89aafe57970f"
version = "0.9.18"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "c47c5fa4c5308f27ccaac35504858d8914e102f9"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.4"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "f7be53659ab06ddc986428d3a9dcc95f6fa6705a"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.2"

[[deps.InlineStrings]]
deps = ["Parsers"]
git-tree-sha1 = "61feba885fac3a407465726d0c330b3055df897f"
uuid = "842dd82b-1e85-43dc-bf29-5d0ee9dffc48"
version = "1.1.2"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.InvertedIndices]]
git-tree-sha1 = "bee5f1ef5bf65df56bdd2e40447590b272a5471f"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.1.0"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "3c837543ddb02250ef42f4738347454f95079d4e"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.3"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "3d3e902b31198a27340d0bf00d6ac452866021cf"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.9"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "bf210ce90b6c9eed32d25dbcae1ebc565df2687f"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.2"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"

[[deps.OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[deps.Parsers]]
deps = ["Dates"]
git-tree-sha1 = "1285416549ccfcdf0c50d4997a94331e88d68413"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.3.1"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "UUIDs"]
git-tree-sha1 = "670e559e5c8e191ded66fa9ea89c97f10376bb4c"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.38"

[[deps.PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "a6062fe4063cdafe78f4a0a81cfffb89721b30e7"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.4.2"

[[deps.PrettyTables]]
deps = ["Crayons", "Formatting", "Markdown", "Reexport", "Tables"]
git-tree-sha1 = "dfb54c4e414caa595a1f2ed759b160f5a3ddcba5"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "1.3.1"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[deps.SentinelArrays]]
deps = ["Dates", "Random"]
git-tree-sha1 = "6a2f7d70512d205ca8c7ee31bfa9f142fe74310c"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.3.12"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "b3363d7460f7d098ca0912c69b082f75625d7508"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.0.1"

[[deps.SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "OrderedCollections", "TableTraits", "Test"]
git-tree-sha1 = "5ce79ce186cc678bbb5c5681ca3379d1ddae11a1"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.7.0"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "216b95ea110b5972db65aa90f88d8d89dcb8851c"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.6"

[[deps.Tricks]]
git-tree-sha1 = "6bac775f2d42a611cdfcd1fb217ee719630c4175"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.6"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.WeakRefStrings]]
deps = ["DataAPI", "InlineStrings", "Parsers"]
git-tree-sha1 = "b1be2855ed9ed8eac54e5caff2afcdb442d52c23"
uuid = "ea10d353-3f73-51f8-a26c-33c1cb351aa5"
version = "1.4.2"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl", "OpenBLAS_jll"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
"""

# ╔═╡ Cell order:
# ╟─3a241435-ea7d-4f24-982d-0ceec9218318
# ╟─58133e6a-6038-446b-ab68-701cfd28ee38
# ╠═36fd3665-c41f-4142-bfe2-260bc7bf000b
# ╠═8a224b4b-f755-40b2-8bed-fad5bb58f785
# ╠═9f130e24-32de-4a63-b8d9-202b5456ba58
# ╠═07ec0a82-f0b7-4788-ae16-8d6ad0a2abf9
# ╟─c04cb8ca-0856-49cf-b8a4-434e9615466c
# ╠═b93b96fc-08ae-457c-b27a-13cc95b9e0c8
# ╠═d2bae887-ec35-45a5-93b8-9cfe5641e8bd
# ╟─7cfedd43-4a2c-49bd-93a0-9e066f626f51
# ╠═50fc9dba-1026-4b57-9eba-a056fa05d1b9
# ╟─21d4a33b-2c6e-4f0a-9ff1-361efa66dd77
# ╠═11e43a42-0e5b-4aea-956d-fc714326ace3
# ╟─d5b601cd-756d-40f8-bf53-9d2a19f3d5e9
# ╠═e2f0dc89-7385-40bf-a76c-b5639f477011
# ╟─3c3804dc-ea57-4458-a83d-2b250b80427d
# ╟─8460f7dd-de9a-4ae3-acf7-3fc63ba09cff
# ╠═7ee22f95-5af8-44e9-983a-a62cffdf00c5
# ╠═c04dd998-bf12-4170-8166-93f1e6dac518
# ╠═2900ed94-edf2-49db-9f3f-ade7dbe7f34e
# ╟─f69e5c6b-85af-49e8-afde-6865d7baba5d
# ╠═ff9ceb7c-1d42-45c9-a65d-8af8b40e0aec
# ╠═8f0a8fff-2634-487c-8063-279f5c1200f7
# ╠═1ed2c24e-3c71-4e2c-b7b5-eafd45aa4625
# ╠═1d36072c-6981-4b99-a864-f1239d717050
# ╠═29c14d56-bfef-4f25-ba17-318a644da2f1
# ╟─7a815ed6-a6fb-4971-b84b-8c566dff6a48
# ╠═1f3e85c1-9d45-4ef5-b218-c9df553c8233
# ╠═a26adba2-3d29-4a7a-9752-1396fe4e4efc
# ╠═360bf1d5-62e9-405d-8c7c-375b73dfe720
# ╠═d073c943-4e4e-4bb3-b667-806bc1147d21
# ╟─32fc00bd-63f8-4c41-a9f4-de79f95651b3
# ╠═42c80dd1-011f-49f5-a2e8-da1fd1042724
# ╟─5230fa1e-7ce7-4c54-9633-5441a410d767
# ╠═ae712ff8-6e16-4487-9fb7-9d105ef05dd9
# ╟─ca9eceb6-f46a-4389-a0a3-d0580242a537
# ╠═21c612b7-d964-42ff-b449-d9b777fcb099
# ╠═fee7e0dd-2cde-4a21-87ae-b2248ff6efe4
# ╠═c64c4d82-2472-42b3-bffa-e5f407c75683
# ╠═c475bef5-4e54-4de5-9721-d7237b697fc1
# ╠═472293ba-9421-4371-8096-9ade3f04b0dd
# ╠═00826089-a9eb-491f-9625-4e71b7ce8801
# ╠═81c35341-002d-45c5-ae4f-16051d1d8297
# ╟─4405fe29-51d0-4bc8-aef6-bf1245ac9f16
# ╠═072f0721-5d0e-406e-82db-545ce1db11ed
# ╠═58aab315-af4c-4329-a94d-1d143d93c518
# ╠═be69af11-b8c3-40ad-b7e1-2ed0dd6432a0
# ╟─22ef1f47-1ced-4f4b-ac60-ce4eb6996eb8
# ╟─e2ad59e3-481e-43bb-8c28-463ceeacc2bf
# ╠═22617b8c-d588-4f6a-86bd-5e84074e0aef
# ╠═e8b36ab8-7e37-4480-a577-3012b91f7459
# ╠═be0be98f-0b55-4703-a7fb-d1ba82ee0f45
# ╠═8bce8540-a97a-431a-80c2-40892fbc85a1
# ╠═4719aca1-3887-4474-8e5a-0260d40d516e
# ╟─929b7157-8038-47c2-9669-632561ce7fe1
# ╠═fd893daa-efa0-411e-9903-8ec82392b2d5
# ╠═7b318091-534b-4173-88bf-d82779a45ed9
# ╟─80e237dd-a910-48f4-96eb-bb9a58998220
# ╟─a242d04e-6898-46b6-bfe3-f3635300ab81
# ╟─91b131ce-fe5c-4182-80bd-c76ae28a5230
# ╟─eea80bb0-9562-4795-9dda-0751f15a6e73
# ╟─a32074ef-c685-4682-935d-688b15f4ea7b
# ╟─5624e59b-5360-41f6-be26-f45d340a5513
# ╟─f6ed47b5-afae-443f-a00f-6874ce4f03d3
# ╟─a18a5446-c3e6-4bf5-b9fa-29473e75d53f
# ╠═cc58b6f5-c3df-4d54-82c4-b688841fdb24
# ╠═cc26848c-1e5e-4af7-8db8-c9b6a7939437
# ╠═746b8029-b76f-44c1-a075-8dea9a4b58a0
# ╠═785849a5-6c29-4e6c-b077-64f06e57af24
# ╠═3701f6e7-8d36-4022-92e6-b75e62436c29
# ╠═41212a6a-dd84-46ef-b840-5dbeed851e4b
# ╠═582878e1-2298-44b8-b836-3738671ec06d
# ╟─8a7eee3a-78aa-40ca-aca6-5b6d63a8e045
# ╠═4b2ba701-7f42-4b10-92f5-2e40bdab315d
# ╠═0977b4ed-845f-4501-9bde-05d1c7ff0602
# ╟─845361e9-c256-40ba-a7ed-a75ddf163b02
# ╟─d5c42dc3-1729-4f03-a7ca-10cefc617382
# ╟─2e6cb744-a504-4203-8c62-839b2d3864b2
# ╠═220f157d-1309-4f29-8bed-8646504f3d72
# ╟─feffb922-d279-4c53-87f1-2db19d2ac697
# ╠═9a50a7c2-c398-4eac-af89-a9a62a00e873
# ╠═0f428918-6733-42f7-b540-2e60ed5b4129
# ╟─f2c19dfa-b360-487f-b3ae-0a453b3e7bbb
# ╠═5265b537-ee35-4151-b2f9-251e65f9e1af
# ╟─1c4b7f07-15a5-4b70-bb6c-8aebfb1524b6
# ╟─b41d8f03-8dad-4e57-818c-25cb5cf46044
# ╠═6f06eac0-c8a2-458a-8573-d6718ed7db15
# ╠═600c127c-f395-4fef-8a7e-9464033701da
# ╟─71cbde30-d2ae-4729-a499-69b842c7c138
# ╠═22ce3784-45a6-49bb-a643-5b25397c849c
# ╠═08948bf5-859b-49db-bef9-2aa47314273e
# ╠═93c50119-b5b3-4ac2-8013-107f0c5218a1
# ╠═c29d6738-e582-4c87-862e-9d26cfc29a9a
# ╠═74a4da92-c5c1-4e2e-8b8a-5c85b0299341
# ╠═21773789-5de7-4df3-b945-31f07fd0eb8e
# ╟─e843330f-f879-45f6-b1cd-3aeb4ca2518d
# ╠═2a5851d0-cf78-4b1a-86d3-3a1859fcfe42
# ╠═f5f15f65-9cb1-46ec-b917-54a5e4d65db7
# ╠═68097a42-8513-4cd9-8159-1e3469294e05
# ╟─23a11ee0-8164-4143-a4ce-1d798c6fc87e
# ╟─bc8a7eda-df0c-49f3-ac52-cec16f31771b
# ╟─66fd248c-1439-4ca9-9a35-f71a92e63760
# ╠═2e7d7d75-9ec8-474a-bb59-5b422e43c418
# ╠═0bacda4a-3395-4d35-8e4d-92bc3ca75b97
# ╠═80370f25-91fe-4cb6-9f85-e6e57064fe11
# ╠═348fbb30-38d5-4f9a-a6c0-27b6e4bdf6ea
# ╠═c4341df9-7387-4d98-9e4c-5c9c9a415579
# ╠═47febd2f-cdda-4222-b74e-8c779d6e092e
# ╠═2dc50016-b862-4113-af43-d03e7bd7c157
# ╟─9d28ee69-cfcd-4692-8a08-09f124f2c735
# ╠═7874ff3f-8dee-4a14-b658-7687b42297ed
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
