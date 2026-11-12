USE CordobaMascotas;
GO

-- Clave sustituta autonumérica; desc y tipo obligatorios, observación opcional
CREATE TABLE atributos_sistema (
    cod_atributo     INT IDENTITY(1,1) NOT NULL,
    desc_atributo    VARCHAR(100)      NOT NULL,
    tipo_dato        VARCHAR(30)       NOT NULL,
    observ_atributo  VARCHAR(255)      NULL,
    CONSTRAINT PK_atributos_sistema PRIMARY KEY (cod_atributo)
);
GO

-- Teléfono opcional (el correo ya es un contacto obligatorio)
CREATE TABLE veterinarias (
    id_veterinaria         INT IDENTITY(1,1) NOT NULL,
    razon_social           VARCHAR(100)      NOT NULL,
    correo                 VARCHAR(100)      NOT NULL,
    telefono               VARCHAR(20)       NULL,
    domicilio              VARCHAR(150)      NOT NULL,
    habilitacion_municipal VARCHAR(30)       NOT NULL,
    CONSTRAINT PK_veterinarias PRIMARY KEY (id_veterinaria)
);
GO

-- cuil CHAR(11) UNIQUE: es el dato del login (RF15)
-- clave: se guarda el hash de la contraseña, no el texto plano
-- habilitado BIT por defecto 1: permite bloquear el acceso sin borrar
CREATE TABLE ciudadanos (
    id_ciudadano  INT IDENTITY(1,1) NOT NULL,
    apellido      VARCHAR(50)       NOT NULL,
    nombre        VARCHAR(50)       NOT NULL,
    cuil          CHAR(11)          NOT NULL,
    clave         VARCHAR(100)      NOT NULL,
    correo        VARCHAR(100)      NOT NULL,
    telefono      VARCHAR(20)       NULL,
    domicilio     VARCHAR(150)      NOT NULL,
    habilitado    BIT               NOT NULL CONSTRAINT DF_ciudadanos_habilitado DEFAULT 1,
    CONSTRAINT PK_ciudadanos PRIMARY KEY (id_ciudadano),
    CONSTRAINT UQ_ciudadanos_cuil UNIQUE (cuil)
);
GO

-- id_responsable NOT NULL: relación con "|" del lado de ciudadanos
-- Es lo que permite saber a qué refugio pertenece el usuario autenticado
CREATE TABLE refugios (
    id_refugio             INT IDENTITY(1,1) NOT NULL,
    razon_social           VARCHAR(100)      NOT NULL,
    correo                 VARCHAR(100)      NOT NULL,
    telefono               VARCHAR(20)       NULL,
    domicilio              VARCHAR(150)      NOT NULL,
    habilitacion_municipal VARCHAR(30)       NOT NULL,
    id_responsable         INT               NOT NULL,
    CONSTRAINT PK_refugios PRIMARY KEY (id_refugio),
    CONSTRAINT FK_refugios_ciudadanos FOREIGN KEY (id_responsable)
        REFERENCES ciudadanos (id_ciudadano)
);
GO

CREATE TABLE tipos_atencion_sanitaria (
    cod_tipo_atencion   INT IDENTITY(1,1) NOT NULL,
    desc_tipo_atencion  VARCHAR(100)      NOT NULL,
    CONSTRAINT PK_tipos_atencion_sanitaria PRIMARY KEY (cod_tipo_atencion)
);
GO

CREATE TABLE rasgos_mascotas (
    cod_rasgo  INT IDENTITY(1,1) NOT NULL,
    nom_rasgo  VARCHAR(50)       NOT NULL,
    CONSTRAINT PK_rasgos_mascotas PRIMARY KEY (cod_rasgo)
);
GO

-- Relación identificante: PK (cod_rasgo, nro_valor_dominio)
-- nro_valor_dominio sin IDENTITY: es un orden dentro de cada rasgo
CREATE TABLE dominio_rasgos_mascotas (
    cod_rasgo          INT          NOT NULL,
    nro_valor_dominio  INT          NOT NULL,
    nom_valor_dominio  VARCHAR(100) NOT NULL,
    CONSTRAINT PK_dominio_rasgos_mascotas PRIMARY KEY (cod_rasgo, nro_valor_dominio),
    CONSTRAINT FK_dominio_rasgos_rasgos FOREIGN KEY (cod_rasgo)
        REFERENCES rasgos_mascotas (cod_rasgo)
);
GO

-- Nombre tal cual figura en el diagrama
CREATE TABLE configuracion_veterinatarias (
    id_veterinaria  INT          NOT NULL,
    cod_atributo    INT          NOT NULL,
    valor           VARCHAR(255) NOT NULL,
    CONSTRAINT PK_configuracion_veterinatarias PRIMARY KEY (id_veterinaria, cod_atributo),
    CONSTRAINT FK_configuracion_veterinarias FOREIGN KEY (id_veterinaria)
        REFERENCES veterinarias (id_veterinaria),
    CONSTRAINT FK_configuracion_atributos FOREIGN KEY (cod_atributo)
        REFERENCES atributos_sistema (cod_atributo)
);
GO

-- id_profesional referencia a ciudadanos (el profesional es un ciudadano)
-- baja: baja lógica, por defecto 0 (en actividad)
CREATE TABLE profesionales_veterinarias (
    id_veterinaria  INT NOT NULL,
    id_profesional  INT NOT NULL,
    baja            BIT NOT NULL CONSTRAINT DF_profesionales_baja DEFAULT 0,
    CONSTRAINT PK_profesionales_veterinarias PRIMARY KEY (id_veterinaria, id_profesional),
    CONSTRAINT FK_profesionales_veterinarias FOREIGN KEY (id_veterinaria)
        REFERENCES veterinarias (id_veterinaria),
    CONSTRAINT FK_profesionales_ciudadanos FOREIGN KEY (id_profesional)
        REFERENCES ciudadanos (id_ciudadano)
);
GO

-- nro_reg_municipal IDENTITY: el sistema municipal asigna el registro
-- sexo con CHECK 'M'/'H'; [año_nacimiento] solo el año (edad aproximada)
-- id_responsable e id_refugio NULL: "o|" del lado padre en el diagrama
CREATE TABLE mascotas (
    nro_reg_municipal  INT IDENTITY(1,1) NOT NULL,
    nombre             VARCHAR(50)       NOT NULL,
    sexo               CHAR(1)           NOT NULL,
    [año_nacimiento]   SMALLINT          NULL,
    microchip          VARCHAR(20)       NULL,
    vive               BIT               NOT NULL CONSTRAINT DF_mascotas_vive DEFAULT 1,
    id_responsable     INT               NULL,
    id_refugio         INT               NULL,
    CONSTRAINT PK_mascotas PRIMARY KEY (nro_reg_municipal),
    CONSTRAINT CK_mascotas_sexo CHECK (sexo IN ('M', 'H')),
    CONSTRAINT FK_mascotas_ciudadanos FOREIGN KEY (id_responsable)
        REFERENCES ciudadanos (id_ciudadano),
    CONSTRAINT FK_mascotas_refugios FOREIGN KEY (id_refugio)
        REFERENCES refugios (id_refugio)
);
GO

-- nro_valor_dominio NULL ("o|" en el diagrama): si el rasgo tiene valores
-- predefinidos (Especie, Raza) se completa; si es libre se usa valor_caracteristica
CREATE TABLE caracteristicas_mascotas (
    nro_reg_municipal    INT          NOT NULL,
    cod_rasgo            INT          NOT NULL,
    nro_caracteristica   INT          NOT NULL,
    nro_valor_dominio    INT          NULL,
    valor_caracteristica VARCHAR(100) NULL,
    CONSTRAINT PK_caracteristicas_mascotas
        PRIMARY KEY (nro_reg_municipal, cod_rasgo, nro_caracteristica),
    CONSTRAINT FK_caracteristicas_mascotas FOREIGN KEY (nro_reg_municipal)
        REFERENCES mascotas (nro_reg_municipal),
    CONSTRAINT FK_caracteristicas_rasgos FOREIGN KEY (cod_rasgo)
        REFERENCES rasgos_mascotas (cod_rasgo),
    CONSTRAINT FK_caracteristicas_dominio FOREIGN KEY (cod_rasgo, nro_valor_dominio)
        REFERENCES dominio_rasgos_mascotas (cod_rasgo, nro_valor_dominio)
);
GO

-- nro_registro sin IDENTITY: es el orden de atención dentro de cada mascota
-- fecha_vencimiento opcional: solo aplica a vacunas y similares
CREATE TABLE informacion_sanitaria (
    nro_reg_municipal  INT           NOT NULL,
    nro_registro       INT           NOT NULL,
    fecha_atencion     DATE          NOT NULL,
    cod_tipo_atencion  INT           NOT NULL,
    detalle_atencion   VARCHAR(500)  NULL,
    fecha_vencimiento  DATE          NULL,
    id_veterinaria     INT           NOT NULL,
    id_profesional     INT           NOT NULL,
    CONSTRAINT PK_informacion_sanitaria PRIMARY KEY (nro_reg_municipal, nro_registro),
    CONSTRAINT FK_informacion_mascotas FOREIGN KEY (nro_reg_municipal)
        REFERENCES mascotas (nro_reg_municipal),
    CONSTRAINT FK_informacion_tipos FOREIGN KEY (cod_tipo_atencion)
        REFERENCES tipos_atencion_sanitaria (cod_tipo_atencion),
    CONSTRAINT FK_informacion_profesionales FOREIGN KEY (id_veterinaria, id_profesional)
        REFERENCES profesionales_veterinarias (id_veterinaria, id_profesional)
);
GO

-- foto VARBINARY(MAX): la imagen queda persistida en SQL Server
-- estado con CHECK: los tres estados del RF13; por defecto 'ACTIVA'
CREATE TABLE publicaciones_adopcion (
    nro_publicacion          INT IDENTITY(1,1) NOT NULL,
    nro_reg_municipal        INT               NOT NULL,
    id_refugio               INT               NOT NULL,
    fecha_publicacion        DATE              NOT NULL CONSTRAINT DF_publicaciones_fecha DEFAULT (CAST(GETDATE() AS DATE)),
    caracteristicas_mascota  VARCHAR(500)      NOT NULL,
    condicion_adopcion       VARCHAR(500)      NOT NULL,
    foto                     VARBINARY(MAX)    NOT NULL,
    estado_publicacion       VARCHAR(15)       NOT NULL CONSTRAINT DF_publicaciones_estado DEFAULT 'ACTIVA',
    CONSTRAINT PK_publicaciones_adopcion PRIMARY KEY (nro_publicacion),
    CONSTRAINT CK_publicaciones_estado CHECK (estado_publicacion IN ('ACTIVA', 'PAUSADA', 'FINALIZADA')),
    CONSTRAINT FK_publicaciones_mascotas FOREIGN KEY (nro_reg_municipal)
        REFERENCES mascotas (nro_reg_municipal),
    CONSTRAINT FK_publicaciones_refugios FOREIGN KEY (id_refugio)
        REFERENCES refugios (id_refugio)
);
GO