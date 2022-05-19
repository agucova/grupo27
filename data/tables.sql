
set check_function_bodies = false;

/* Table 'aerolinea' */
create table aerolinea(
  id serial not null,
  nombre varchar(80) not null,
  codigo char(3) not null,
  primary key(id)
);

/* Table 'tripulacion' */
create table tripulacion(
  id serial not null,
  nombre varchar(120) not null,
  fecha_nacimiento date not null,
  pasaporte varchar(40) not null,
  primary key(id)
);

/* Table 'vuelo' */
create table vuelo(
  id serial not null,
  id_aerolinea integer not null,
  id_origen integer not null,
  id_destino integer not null,
  id_avion integer not null,
  id_ruta integer not null,
  id_piloto integer not null,
  id_copiloto integer not null,
  codigo varchar(20) not null,
  fecha_salida timestamp with time zone not null,
  fecha_llegada timestamp with time zone not null,
  velocidad float8 not null,
  altitud float8 not null,
  estado varchar(20),
  primary key(id)
);

/* Table 'tripulacion_vuelo' */
create table tripulacion_vuelo(
id_tripulante integer not null, id_vuelo integer not null,
  rol varchar(40) not null
);

/* Table 'aerodromo' */
create table aerodromo(
  id serial not null,
  nombre varchar(50) not null,
  icao char(4) not null,
  iata char(3) not null,
  posicion point not null,
  id_ciudad integer not null,
  primary key(id)
);

/* Table 'ciudad' */
create table ciudad(
  id integer not null,
  nombre varchar(60),
  id_pais integer not null,
  primary key(id)
);

/* Table 'punto_ruta' */
create table punto_ruta(
  id serial not null,
  id_ruta integer not null,
  indice integer not null,
  nombre varchar(100) not null,
  posicion point not null,
  primary key(id)
);

/* Table 'pasajero' */
create table pasajero(
  id serial not null,
  nombre varchar(50) not null,
  fecha_nacimiento date not null,
  nacionalidad varchar(50) not null,
  pasaporte varchar(40),
  primary key(id)
);

/* Table 'reserva' */
create table reserva(
  id integer not null,
  id_reservante integer not null,
  codigo varchar(12) not null,
  primary key(id)
);

/* Table 'ticket' */
create table ticket(
  id integer not null,
  id_vuelo integer not null,
  id_pasajero integer not null,
  id_reserva integer not null,
  asiento integer not null,
  clase varchar(20) not null,
  comida_y_maleta boolean not null,
  primary key(id)
);

/* Table 'costo' */
create table costo
  (id_ruta integer not null, id_avion integer not null, costo numeric);

/* Table 'avion' */
create table avion(
  id serial not null,
  nombre varchar(50) not null,
  modelo varchar(50) not null,
  peso float8 not null,
  codigo char(7) not null,
  primary key(id)
);

/* Table 'ruta' */
create table ruta
  (id serial not null, nombre varchar(6) not null, primary key(id));

/* Table 'pais' */
create table pais
  (id serial not null, nombre varchar(80) not null, primary key(id));

/* Table 'piloto' */
create table piloto(
  id serial not null,
  nombre varchar(120) not null,
  fecha_nacimiento date not null,
  pasaporte varchar(40) not null,
  licencia varchar(50) not null,
  primary key(id)
);

/* Relation 'Tripulacion_TripulacionVuelo' */
alter table tripulacion_vuelo
  add constraint "Tripulacion_TripulacionVuelo"
    foreign key (id_tripulante) references tripulacion (id);

/* Relation 'Vuelo_TripulacionVuelo' */
alter table tripulacion_vuelo
  add constraint "Vuelo_TripulacionVuelo"
    foreign key (id_vuelo) references vuelo (id);

/* Relation 'Ciudad_Aerodromo' */
alter table aerodromo
  add constraint "Ciudad_Aerodromo" foreign key (id_ciudad) references ciudad (id)
  ;

/* Relation 'Vuelo_Ticket' */
alter table ticket
  add constraint "Vuelo_Ticket" foreign key (id_vuelo) references vuelo (id);

/* Relation 'Pasajero_Ticket' */
alter table ticket
  add constraint "Pasajero_Ticket"
    foreign key (id_pasajero) references pasajero (id);

/* Relation 'Pasajero_Reserva' */
alter table reserva
  add constraint "Pasajero_Reserva"
    foreign key (id_reservante) references pasajero (id);

/* Relation 'Avion_Costo' */
alter table costo
  add constraint "Avion_Costo" foreign key (id_avion) references avion (id);

/* Relation 'Origen_Vuelo' */
alter table vuelo
  add constraint "Origen_Vuelo"
    foreign key (id_origen) references aerodromo (id);

/* Relation 'Destino_Vuelo' */
alter table vuelo
  add constraint "Destino_Vuelo"
    foreign key (id_destino) references aerodromo (id);

/* Relation 'Aerolinea_Vuelo' */
alter table vuelo
  add constraint "Aerolinea_Vuelo"
    foreign key (id_aerolinea) references aerolinea (id);

/* Relation 'Avion_Vuelo' */
alter table vuelo
  add constraint "Avion_Vuelo" foreign key (id_avion) references avion (id);

/* Relation 'ruta_punto_ruta' */
alter table punto_ruta
  add constraint ruta_punto_ruta foreign key (id_ruta) references ruta (id);

/* Relation 'ruta_costo' */
alter table costo
  add constraint ruta_costo foreign key (id_ruta) references ruta (id);

/* Relation 'ruta_vuelo' */
alter table vuelo
  add constraint ruta_vuelo foreign key (id_ruta) references ruta (id);

/* Relation 'reserva_ticket' */
alter table ticket
  add constraint reserva_ticket foreign key (id_reserva) references reserva (id)
  ;

/* Relation 'pais_ciudad' */
alter table ciudad
  add constraint pais_ciudad foreign key (id_pais) references pais (id);

/* Relation 'piloto_vuelo' */
alter table vuelo
  add constraint piloto_vuelo foreign key (id_piloto) references piloto (id);

/* Relation 'piloto_vuelo' */
alter table vuelo
  add constraint copiloto_vuelo foreign key (id_copiloto) references piloto (id);
