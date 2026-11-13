USE CordobaMascotas;
GO

SET IDENTITY_INSERT rasgos_mascotas ON;
INSERT INTO rasgos_mascotas (cod_rasgo, nom_rasgo) VALUES
    (1, 'Especie'),
    (2, 'Raza'),
    (3, 'Pelaje');
SET IDENTITY_INSERT rasgos_mascotas OFF;
GO

INSERT INTO dominio_rasgos_mascotas (cod_rasgo, nro_valor_dominio, nom_valor_dominio) VALUES
    (1, 1, 'Perro'),
    (1, 2, 'Gato'),
    (2, 1, 'Labrador'),
    (2, 2, 'Mestizo'),
    (2, 3, 'Siamés'),
    (3, 1, 'Corto'),
    (3, 2, 'Largo');
GO

SET IDENTITY_INSERT tipos_atencion_sanitaria ON;
INSERT INTO tipos_atencion_sanitaria (cod_tipo_atencion, desc_tipo_atencion) VALUES
    (1, 'Vacunación'),
    (2, 'Desparasitación'),
    (3, 'Esterilización'),
    (4, 'Castración');
SET IDENTITY_INSERT tipos_atencion_sanitaria OFF;
GO

SET IDENTITY_INSERT ciudadanos ON;
INSERT INTO ciudadanos (id_ciudadano, apellido, nombre, cuil, clave, correo, telefono, domicilio, habilitado) VALUES
    (1, 'Gómez', 'Laura', '27301234568', 'clave123', 'laura.gomez@mail.com', '3515551111', 'Av. Colón 1250, Córdoba', 1),
    (2, 'Pérez', 'Martín', '20285678901', 'clave123', 'martin.perez@mail.com', '3515552222', 'Bv. San Juan 800, Córdoba', 1),
    (3, 'Suárez', 'Ana', '27334455667', 'clave123', 'ana.suarez@mail.com', NULL, 'Av. Vélez Sarsfield 300, Córdoba', 0);
SET IDENTITY_INSERT ciudadanos OFF;
GO

SET IDENTITY_INSERT refugios ON;
INSERT INTO refugios (id_refugio, razon_social, correo, telefono, domicilio, habilitacion_municipal, id_responsable) VALUES
    (1, 'Refugio Patitas Felices', 'patitas@mail.com', '3515553333', 'Calle Falsa 123, Córdoba', 'HAB-001', 1),
    (2, 'Hogar Animal Córdoba', 'hogar@mail.com', '3515554444', 'Av. Circunvalación 500, Córdoba', 'HAB-002', 2);
SET IDENTITY_INSERT refugios OFF;
GO

SET IDENTITY_INSERT mascotas ON;
INSERT INTO mascotas (nro_reg_municipal, nombre, sexo, [año_nacimiento], microchip, vive, id_responsable, id_refugio) VALUES
    (1, 'Luna', 'H', 2022, '985112345678901', 1, NULL, 1),
    (2, 'Toby', 'M', 2020, NULL, 1, NULL, 1),
    (3, 'Michi', 'H', 2023, NULL, 1, NULL, 1),
    (4, 'Rocky', 'M', 2019, '985112345678902', 1, NULL, 2),
    (5, 'Bruno', 'M', 2021, NULL, 1, NULL, 1);
SET IDENTITY_INSERT mascotas OFF;
GO

INSERT INTO caracteristicas_mascotas (nro_reg_municipal, cod_rasgo, nro_caracteristica, nro_valor_dominio, valor_caracteristica) VALUES
    (1, 1, 1, 1, NULL),
    (1, 2, 1, 1, NULL),
    (1, 3, 1, 1, NULL),
    (2, 1, 1, 1, NULL),
    (2, 2, 1, 2, NULL),
    (2, 3, 1, 2, NULL),
    (3, 1, 1, 2, NULL),
    (3, 2, 1, 3, NULL),
    (3, 3, 1, 1, NULL),
    (4, 1, 1, 1, NULL),
    (4, 2, 1, 2, NULL),
    (4, 3, 1, 1, NULL),
    (5, 1, 1, 1, NULL),
    (5, 2, 1, 2, NULL);
GO

SET IDENTITY_INSERT publicaciones_adopcion ON;
INSERT INTO publicaciones_adopcion (nro_publicacion, nro_reg_municipal, id_refugio, fecha_publicacion, caracteristicas_mascota, condicion_adopcion, foto, estado_publicacion) VALUES
    (1, 1, 1, '2026-11-07', 'Luna es cariñosa y juguetona, ideal para familias con niños.', 'Patio o espacio al aire libre. Seguimiento durante 3 meses.', CAST('foto-luna' AS VARBINARY(MAX)), 'ACTIVA'),
    (2, 2, 1, '2026-11-07', 'Toby es tranquilo y sociable con otros perros.', 'Contrato de adopción responsable.', CAST('foto-toby' AS VARBINARY(MAX)), 'ACTIVA'),
    (3, 3, 1, '2026-11-07', 'Michi es independiente y muy limpia.', 'Mosquiteros en ventanas y balcones.', CAST('foto-michi' AS VARBINARY(MAX)), 'FINALIZADA'),
    (4, 4, 2, '2026-11-07', 'Rocky es energético, necesita paseos diarios.', 'Compromiso de paseos diarios y visitas de control.', CAST('foto-rocky' AS VARBINARY(MAX)), 'ACTIVA'),
    (5, 5, 1, '2026-11-07', 'Bruno es dócil y cariñoso.', 'Casa con espacio.', CAST('foto-nueva' AS VARBINARY(MAX)), 'FINALIZADA');
SET IDENTITY_INSERT publicaciones_adopcion OFF;
GO
