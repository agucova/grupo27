set check_function_bodies = false;


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
drop table if exists maneja cascade;
drop table if exists licencia cascade;

/* Table 'aerolinea' */
create table aerolinea(
  id serial not null,
  codigo char(3) not null,
  nombre varchar(80) not null,
  primary key(id),
  constraint codigo_aerolinea unique(codigo)
);

/* Table 'trabajador' */
create table trabajador(
  id serial not null,
  pasaporte varchar(40) not null,
  nombre varchar(120) not null,
  fecha_nacimiento date not null,
  primary key(id),
  constraint pasaporte_tripulacion unique(pasaporte)
);

/* Table 'vuelo' */
create table vuelo(
  id serial not null,
  id_aerolinea integer not null,
  id_origen integer not null,
  id_destino integer not null,
  id_avion integer not null,
  id_ruta integer not null,
  codigo varchar(20) not null,
  fecha_salida timestamp with time zone not null,
  fecha_llegada timestamp with time zone not null,
  velocidad float8 not null,
  altitud float8 not null,
  estado varchar(20),
  primary key(id)
);

/* Table 'tripulante_vuelo' */
create table tripulante_vuelo(
id_vuelo integer not null, id_tripulante integer not null,
  primary key(id_vuelo, id_tripulante)
);

/* Table 'aerodromo' */
create table aerodromo(
  id serial not null,
  icao char(4) not null,
  iata char(3) not null,
  id_ciudad integer not null,
  nombre varchar(120) not null,
  posicion point not null,
  primary key(id),
  constraint icao unique(icao),
  constraint iata unique(iata)
);

/* Table 'ciudad' */
create table ciudad(
  id integer not null,
  id_pais integer not null,
  nombre varchar(60) not null,
  primary key(id)
);

/* Table 'punto_ruta' */
create table punto_ruta(
  id_ruta integer not null,
  indice integer not null,
  nombre varchar(100) not null,
  posicion point not null,
  primary key(indice, id_ruta)
);

/* Table 'pasajero' */
create table pasajero(
  id serial not null,
  pasaporte varchar(40) not null,
  nombre varchar(50) not null,
  fecha_nacimiento date not null,
  nacionalidad varchar(50) not null,
  primary key(id),
  constraint pasaporte_pasajero unique(pasaporte)
);

/* Table 'reserva' */
create table reserva(
  id integer not null,
  codigo varchar(12) not null,
  id_reservante integer not null,
  primary key(id),
  constraint codigo_reserva unique(codigo)
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
create table costo(
  id_ruta integer not null,
  id_modelo integer not null,
  monto numeric not null,
  primary key(id_ruta, id_modelo)
);

/* Table 'avion' */
create table avion(
  id serial not null,
  codigo char(7) not null,
  id_modelo integer not null,
  primary key(id),
  constraint "Codigo" unique(codigo)
);

/* Table 'ruta' */
create table ruta
  (id serial not null, nombre varchar(6) not null, primary key(id));

/* Table 'pais' */
create table pais
  (id serial not null, nombre varchar(80) not null, primary key(id));

/* Table 'piloto' */
create table piloto(id_trabajador integer not null, primary key(id_trabajador));

/* Table 'licencia' */
create table licencia
  (id integer not null, id_piloto integer not null, primary key(id));

/* Table 'piloto_vuelo' */
create table piloto_vuelo(
  id_vuelo integer not null,
  id_piloto integer not null,
  id_licencia integer not null,
  rol char(30) not null,
  primary key(id_vuelo, id_piloto)
);

/* Table 'modelo' */
create table modelo(
  id integer not null,
  peso float8(120) not null,
  codigo varchar(40) not null,
  nombre varchar(100) not null,
  primary key(id)
);

/* Table 'trabajador_aerolinea' */
create table trabajador_aerolinea(
id_trabajador integer not null, id_aerolinea integer not null,
  primary key(id_trabajador, id_aerolinea)
);

/* Table 'tripulante' */
create table tripulante
  (id_trabajador integer not null, rol varchar(50), primary key(id_trabajador));

/* Relation 'vuelo_tripulacionvuelo' */
alter table tripulante_vuelo
  add constraint vuelo_tripulacionvuelo
    foreign key (id_vuelo) references vuelo (id);

/* Relation 'ciudad_aerodromo' */
alter table aerodromo
  add constraint ciudad_aerodromo foreign key (id_ciudad) references ciudad (id)
  ;

/* Relation 'vuelo_ticket' */
alter table ticket
  add constraint vuelo_ticket foreign key (id_vuelo) references vuelo (id);

/* Relation 'pasajero_ticket' */
alter table ticket
  add constraint pasajero_ticket
    foreign key (id_pasajero) references pasajero (id);

/* Relation 'pasajero_reserva' */
alter table reserva
  add constraint pasajero_reserva
    foreign key (id_reservante) references pasajero (id);

/* Relation 'origen_vuelo' */
alter table vuelo
  add constraint origen_vuelo
    foreign key (id_origen) references aerodromo (id);

/* Relation 'destino_vuelo' */
alter table vuelo
  add constraint destino_vuelo foreign key (id_destino) references aerodromo (id)
  ;

/* Relation 'aerolinea_vuelo' */
alter table vuelo
  add constraint aerolinea_vuelo
    foreign key (id_aerolinea) references aerolinea (id);

/* Relation 'avion_vuelo' */
alter table vuelo
  add constraint avion_vuelo foreign key (id_avion) references avion (id);

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

/* Relation 'piloto_licencia' */
alter table licencia
  add constraint piloto_licencia
    foreign key (id_piloto) references piloto (id_trabajador);

/* Relation 'vuelo_maneja' */
alter table piloto_vuelo
  add constraint vuelo_maneja foreign key (id_vuelo) references vuelo (id);

/* Relation 'piloto_maneja' */
alter table piloto_vuelo
  add constraint piloto_maneja
    foreign key (id_piloto) references piloto (id_trabajador);

/* Relation 'licencia_maneja' */
alter table piloto_vuelo
  add constraint licencia_maneja
    foreign key (id_licencia) references licencia (id);

/* Relation 'modelo_avion' */
alter table avion
  add constraint modelo_avion foreign key (id_modelo) references modelo (id);

/* Relation 'modelo_costo' */
alter table costo
  add constraint modelo_costo foreign key (id_modelo) references modelo (id);

/* Relation 'trabajador_trabajador_aerolinea' */
alter table trabajador_aerolinea
  add constraint trabajador_trabajador_aerolinea
    foreign key (id_trabajador) references trabajador (id);

/* Relation 'aerolinea_trabajador_aerolinea' */
alter table trabajador_aerolinea
  add constraint aerolinea_trabajador_aerolinea
    foreign key (id_aerolinea) references aerolinea (id);

/* Relation 'trabajador_piloto' */
alter table piloto
  add constraint trabajador_piloto
    foreign key (id_trabajador) references trabajador (id);

/* Relation 'tripulante_tripulante_vuelo' */
alter table tripulante_vuelo
  add constraint tripulante_tripulante_vuelo
    foreign key (id_tripulante) references tripulante (id_trabajador);

/* Relation 'trabajador_tripulante' */
alter table tripulante
  add constraint trabajador_tripulante
    foreign key (id_trabajador) references trabajador (id);
