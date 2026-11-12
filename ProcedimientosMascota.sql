USE CordobaMascotas;
GO

-- Las contraseñas pasan a guardarse como hash SHA-256 (64 caracteres hex)
UPDATE ciudadanos
SET clave = CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', 'clave123'), 2);
GO

-- RF15: valida CUIL + contraseña. Devuelve 1 fila si son correctos, 0 filas si no.
CREATE OR ALTER PROCEDURE sp_login
    @cuil  CHAR(11),
    @clave VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT c.id_ciudadano, c.apellido, c.nombre, r.id_refugio, r.razon_social
    FROM ciudadanos c
    JOIN refugios r ON r.id_responsable = c.id_ciudadano
    WHERE c.cuil = @cuil
      AND c.clave = CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', @clave), 2)
      AND c.habilitado = 1;
END
GO

-- RF13: lista las publicaciones del refugio
CREATE OR ALTER PROCEDURE sp_listar_publicaciones
    @id_refugio INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT p.nro_publicacion,
           m.nombre,
           (SELECT TOP 1 d.nom_valor_dominio
              FROM caracteristicas_mascotas c
              JOIN rasgos_mascotas r ON r.cod_rasgo = c.cod_rasgo
              JOIN dominio_rasgos_mascotas d ON d.cod_rasgo = c.cod_rasgo
                                            AND d.nro_valor_dominio = c.nro_valor_dominio
             WHERE c.nro_reg_municipal = m.nro_reg_municipal
               AND r.nom_rasgo = 'Especie') AS especie,
           m.sexo,
           YEAR(GETDATE()) - m.[año_nacimiento] AS edad_aproximada,
           (SELECT TOP 1 d.nom_valor_dominio
              FROM caracteristicas_mascotas c
              JOIN rasgos_mascotas r ON r.cod_rasgo = c.cod_rasgo
              JOIN dominio_rasgos_mascotas d ON d.cod_rasgo = c.cod_rasgo
                                            AND d.nro_valor_dominio = c.nro_valor_dominio
             WHERE c.nro_reg_municipal = m.nro_reg_municipal
               AND r.nom_rasgo = 'Raza') AS raza,
           p.caracteristicas_mascota,
           p.condicion_adopcion,
           p.foto,
           p.estado_publicacion,
           p.fecha_publicacion
    FROM publicaciones_adopcion p
    JOIN mascotas m ON m.nro_reg_municipal = p.nro_reg_municipal
    WHERE p.id_refugio = @id_refugio
    ORDER BY p.fecha_publicacion DESC, p.nro_publicacion DESC;
END
GO

-- Valores para los desplegables del formulario (nom_rasgo = 'Especie' o 'Raza')
CREATE OR ALTER PROCEDURE sp_listar_dominio
    @nom_rasgo VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT d.nro_valor_dominio, d.nom_valor_dominio
    FROM dominio_rasgos_mascotas d
    JOIN rasgos_mascotas r ON r.cod_rasgo = d.cod_rasgo
    WHERE r.nom_rasgo = @nom_rasgo
    ORDER BY d.nom_valor_dominio;
END
GO

-- RF13: alta de publicación (crea la mascota, sus características y la publicación)
CREATE OR ALTER PROCEDURE sp_alta_publicacion
    @id_refugio         INT,
    @nombre             VARCHAR(50),
    @sexo               CHAR(1),
    @anio_nacimiento    SMALLINT,
    @nro_especie        INT,
    @nro_raza           INT,
    @caracteristicas    VARCHAR(500),
    @condicion_adopcion VARCHAR(500),
    @foto               VARBINARY(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @cod_especie INT = (SELECT cod_rasgo FROM rasgos_mascotas WHERE nom_rasgo = 'Especie');
    DECLARE @cod_raza    INT = (SELECT cod_rasgo FROM rasgos_mascotas WHERE nom_rasgo = 'Raza');
    DECLARE @nro_reg     INT;

    BEGIN TRANSACTION;

    INSERT INTO mascotas (nombre, sexo, [año_nacimiento], vive, id_refugio)
    VALUES (@nombre, @sexo, @anio_nacimiento, 1, @id_refugio);
    SET @nro_reg = SCOPE_IDENTITY();

    INSERT INTO caracteristicas_mascotas (nro_reg_municipal, cod_rasgo, nro_caracteristica, nro_valor_dominio)
    VALUES (@nro_reg, @cod_especie, 1, @nro_especie),
           (@nro_reg, @cod_raza,    1, @nro_raza);

    INSERT INTO publicaciones_adopcion (nro_reg_municipal, id_refugio, caracteristicas_mascota, condicion_adopcion, foto)
    VALUES (@nro_reg, @id_refugio, @caracteristicas, @condicion_adopcion, @foto);

    COMMIT TRANSACTION;

    SELECT SCOPE_IDENTITY() AS nro_publicacion;
END
GO

-- RF13: activar / pausar / finalizar. Devuelve cuántas filas cambió (0 = operación no permitida)
CREATE OR ALTER PROCEDURE sp_cambiar_estado
    @nro_publicacion INT,
    @id_refugio      INT,
    @nuevo_estado    VARCHAR(15)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE publicaciones_adopcion
    SET estado_publicacion = @nuevo_estado
    WHERE nro_publicacion = @nro_publicacion
      AND id_refugio = @id_refugio
      AND (   (estado_publicacion = 'ACTIVA'  AND @nuevo_estado IN ('PAUSADA', 'FINALIZADA'))
           OR (estado_publicacion = 'PAUSADA' AND @nuevo_estado IN ('ACTIVA', 'FINALIZADA')));

    SELECT @@ROWCOUNT AS filas;
END
GO