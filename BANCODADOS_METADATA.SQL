CREATE DATABASE "Frota"
  WITH OWNER = postgres
       ENCODING = 'UTF8'
       TABLESPACE = pg_default
       LC_COLLATE = 'pt_BR.UTF-8'
       LC_CTYPE = 'pt_BR.UTF-8'
       CONNECTION LIMIT = -1;


      CREATE TABLE veiculo
(
  codigo character varying(3),
  dataregistro date,
  marca character varying(30),
  modelo character varying(30),
  placa character varying(8),
  ano character varying(4),
  renavam character varying(30),
  motorista dnome,
  valormercado numeric(12,2),
  tipo_horimetro character(1),
  motor integer,
  cambio integer,
  diferencial integer,
  filtrooleo integer,
  filtroar integer,
  km integer,
  ult_km integer,
  data_ult_km date,
  combustivel character(2),
  descricao character varying(50),
  hidraulico integer,
  transmissao integer,
  tandem integer,
  filtrodiesel integer,
  filtropu integer,
  trocatempo integer DEFAULT 0,
  filtroracor integer,
  filtrohidraulico integer,
  filtroseparadoragua integer,
  filtrosecadorar integer,
  filtroseguranca integer,
  obs bytea
)
WITH (
  OIDS=FALSE
);
ALTER TABLE veiculo
  OWNER TO postgres;

-- Index: idx_veiculo_codigo

-- DROP INDEX idx_veiculo_codigo;

CREATE INDEX idx_veiculo_codigo
  ON veiculo
  USING btree
  (codigo COLLATE pg_catalog."default");

-- Index: idx_veiculo_placa

-- DROP INDEX idx_veiculo_placa;

CREATE INDEX idx_veiculo_placa
  ON veiculo
  USING btree
  (placa COLLATE pg_catalog."default");

 