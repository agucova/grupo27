
SET check_function_bodies = false;

/* Table 'aerolinea' */
CREATE TABLE aerolinea(
  id serial NOT NULL,
  nombre varchar(80) NOT NULL,
  codigo char(3) NOT NULL,
  PRIMARY KEY(id)
);

/* Table 'tripulacion' */
CREATE TABLE tripulacion(
  id serial NOT NULL,
  nombre varchar(120) NOT NULL,
  fecha_nacimiento date NOT NULL,
  pasaporte varchar(40) NOT NULL,
  PRIMARY KEY(id)
);

/* Table 'vuelo' */
CREATE TABLE vuelo(
  id serial NOT NULL,
  id_aerolinea integer NOT NULL,
  id_origen integer NOT NULL,
  id_destino integer NOT NULL,
  id_avion integer NOT NULL,
  id_ruta integer NOT NULL,
  id_piloto integer NOT NULL,
  id_copiloto integer NOT NULL,
  codigo varchar(20) NOT NULL,
  fecha_salida timestamp with time zone NOT NULL,
  fecha_llegada timestamp with time zone NOT NULL,
  velocidad float8 NOT NULL,
  altitud float8 NOT NULL,
  estado varchar(20),
  PRIMARY KEY(id)
);

/* Table 'tripulacion_vuelo' */
CREATE TABLE tripulacion_vuelo(
id_tripulante integer NOT NULL, id_vuelo integer NOT NULL,
  rol varchar(40) NOT NULL
);

/* Table 'aerodromo' */
CREATE TABLE aerodromo(
  id serial NOT NULL,
  nombre varchar(50) NOT NULL,
  icao char(4) NOT NULL,
  iata char(3) NOT NULL,
  posicion point NOT NULL,
  id_ciudad integer NOT NULL,
  PRIMARY KEY(id)
);

/* Table 'ciudad' */
CREATE TABLE ciudad(
  id integer NOT NULL,
  nombre varchar(60),
  id_pais integer NOT NULL,
  PRIMARY KEY(id)
);

/* Table 'punto_ruta' */
CREATE TABLE punto_ruta(
  id serial NOT NULL,
  id_ruta integer NOT NULL,
  indice integer NOT NULL,
  nombre varchar(100) NOT NULL,
  posicion point NOT NULL,
  PRIMARY KEY(id)
);

/* Table 'pasajero' */
CREATE TABLE pasajero(
  id serial NOT NULL,
  nombre varchar(50) NOT NULL,
  fecha_nacimiento date NOT NULL,
  nacionalidad varchar(50) NOT NULL,
  pasaporte varchar(40),
  PRIMARY KEY(id)
);

/* Table 'reserva' */
CREATE TABLE reserva(
  id integer NOT NULL,
  id_reservante integer NOT NULL,
  codigo varchar(12) NOT NULL,
  PRIMARY KEY(id)
);

/* Table 'ticket' */
CREATE TABLE ticket(
  id integer NOT NULL,
  id_vuelo integer NOT NULL,
  id_pasajero integer NOT NULL,
  id_reserva integer NOT NULL,
  asiento integer NOT NULL,
  clase varchar(20) NOT NULL,
  comida_y_maleta boolean NOT NULL,
  PRIMARY KEY(id)
);

/* Table 'costo' */
CREATE TABLE costo
  (id_ruta integer NOT NULL, id_avion integer NOT NULL, costo numeric);

/* Table 'avion' */
CREATE TABLE avion(
  id serial NOT NULL,
  nombre varchar(50) NOT NULL,
  modelo varchar(50) NOT NULL,
  peso float8 NOT NULL,
  codigo char(7) NOT NULL,
  PRIMARY KEY(id)
);

/* Table 'ruta' */
CREATE TABLE ruta
  (id serial NOT NULL, nombre varchar(6) NOT NULL, PRIMARY KEY(id));

/* Table 'pais' */
CREATE TABLE pais
  (id serial NOT NULL, nombre varchar(80) NOT NULL, PRIMARY KEY(id));

/* Table 'piloto' */
CREATE TABLE piloto(
  id serial NOT NULL,
  nombre varchar(120) NOT NULL,
  fecha_nacimiento date NOT NULL,
  pasaporte varchar(40) NOT NULL,
  PRIMARY KEY(id)
);

/* Table 'licencia' */
CREATE TABLE licencia(
  id integer NOT NULL,
  id_piloto integer NOT NULL,
  "Id_aerolinea" integer NOT NULL,
  PRIMARY KEY(id)
);

/* Relation 'Tripulacion_TripulacionVuelo' */
ALTER TABLE tripulacion_vuelo
  ADD CONSTRAINT "Tripulacion_TripulacionVuelo"
    FOREIGN KEY (id_tripulante) REFERENCES tripulacion (id);

/* Relation 'Vuelo_TripulacionVuelo' */
ALTER TABLE tripulacion_vuelo
  ADD CONSTRAINT "Vuelo_TripulacionVuelo"
    FOREIGN KEY (id_vuelo) REFERENCES vuelo (id);

/* Relation 'Ciudad_Aerodromo' */
ALTER TABLE aerodromo
  ADD CONSTRAINT "Ciudad_Aerodromo" FOREIGN KEY (id_ciudad) REFERENCES ciudad (id)
  ;

/* Relation 'Vuelo_Ticket' */
ALTER TABLE ticket
  ADD CONSTRAINT "Vuelo_Ticket" FOREIGN KEY (id_vuelo) REFERENCES vuelo (id);

/* Relation 'Pasajero_Ticket' */
ALTER TABLE ticket
  ADD CONSTRAINT "Pasajero_Ticket"
    FOREIGN KEY (id_pasajero) REFERENCES pasajero (id);

/* Relation 'Pasajero_Reserva' */
ALTER TABLE reserva
  ADD CONSTRAINT "Pasajero_Reserva"
    FOREIGN KEY (id_reservante) REFERENCES pasajero (id);

/* Relation 'Avion_Costo' */
ALTER TABLE costo
  ADD CONSTRAINT "Avion_Costo" FOREIGN KEY (id_avion) REFERENCES avion (id);

/* Relation 'Origen_Vuelo' */
ALTER TABLE vuelo
  ADD CONSTRAINT "Origen_Vuelo"
    FOREIGN KEY (id_origen) REFERENCES aerodromo (id);

/* Relation 'Destino_Vuelo' */
ALTER TABLE vuelo
  ADD CONSTRAINT "Destino_Vuelo"
    FOREIGN KEY (id_destino) REFERENCES aerodromo (id);

/* Relation 'Aerolinea_Vuelo' */
ALTER TABLE vuelo
  ADD CONSTRAINT "Aerolinea_Vuelo"
    FOREIGN KEY (id_aerolinea) REFERENCES aerolinea (id);

/* Relation 'Avion_Vuelo' */
ALTER TABLE vuelo
  ADD CONSTRAINT "Avion_Vuelo" FOREIGN KEY (id_avion) REFERENCES avion (id);

/* Relation 'ruta_punto_ruta' */
ALTER TABLE punto_ruta
  ADD CONSTRAINT ruta_punto_ruta FOREIGN KEY (id_ruta) REFERENCES ruta (id);

/* Relation 'ruta_costo' */
ALTER TABLE costo
  ADD CONSTRAINT ruta_costo FOREIGN KEY (id_ruta) REFERENCES ruta (id);

/* Relation 'ruta_vuelo' */
ALTER TABLE vuelo
  ADD CONSTRAINT ruta_vuelo FOREIGN KEY (id_ruta) REFERENCES ruta (id);

/* Relation 'reserva_ticket' */
ALTER TABLE ticket
  ADD CONSTRAINT reserva_ticket FOREIGN KEY (id_reserva) REFERENCES reserva (id)
  ;

/* Relation 'pais_ciudad' */
ALTER TABLE ciudad
  ADD CONSTRAINT pais_ciudad FOREIGN KEY (id_pais) REFERENCES pais (id);

/* Relation 'piloto_vuelo' */
ALTER TABLE vuelo
  ADD CONSTRAINT piloto_vuelo FOREIGN KEY (id_piloto) REFERENCES piloto (id);

/* Relation 'piloto_vuelo' */
ALTER TABLE vuelo
  ADD CONSTRAINT piloto_vuelo FOREIGN KEY (id_copiloto) REFERENCES piloto (id);

/* Relation 'piloto_licencia' */
ALTER TABLE licencia
  ADD CONSTRAINT piloto_licencia FOREIGN KEY (id_piloto) REFERENCES piloto (id);

/* Relation 'aerolinea_licencia' */
ALTER TABLE licencia
  ADD CONSTRAINT aerolinea_licencia
    FOREIGN KEY ("Id_aerolinea") REFERENCES aerolinea (id);