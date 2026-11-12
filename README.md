# Mascotas Córdoba – Parcial III (perfil Refugio)

Diseño Avanzado de Software – Ingeniería en Informática (UBP). Desarrollo de los requerimientos **RF13 – Gestionar publicaciones de adopción** y **RF15 – Autenticar usuarios** del sistema *Mascotas Córdoba – Programa Municipal de Bienestar Animal*, solo para el perfil **Refugio**.

El modelo de datos completo (DER y justificación de cada tabla) está en [`DER.md`](DER.md).

## 1. Alcance

| Requerimiento | Qué se implementó |
|---|---|
| RF15 | Ingreso con **CUIL y contraseña**, validado dentro de la propia aplicación (sin CiDi ni proveedores externos). Se mantiene el contexto de la sesión. |
| RF13 | Listado de publicaciones del refugio (foto, nombre, especie, sexo, edad aproximada, raza, descripción y condiciones de adopción), **alta** de publicaciones con foto y cambio de estado **Activa / Pausada / Finalizada**. |
| Fuera de alcance | Edición de publicaciones (según la consigna). Registro de usuarios (se consideran previamente registrados). |

## 2. Tecnologías

| Capa | Tecnología |
|---|---|
| Frontend | Angular (componentes standalone) + Bootstrap |
| Backend | Spring Boot 4.1 + `JdbcTemplate` (JDBC) |
| Base de datos | Microsoft SQL Server (base `CordobaMascotas`) |
| Comunicación | Servicios REST con JSON |

## 3. Estructura del proyecto

```
<repositorio>/
├── MascotasVeteBack/            Backend (Spring Boot)
│   └── src/main/java/com/example/demo/
│       ├── DemoApplication.java
│       ├── config/              SecurityConfig (JWT, CORS, rutas protegidas)
│       ├── resource/            Controladores REST        (presentación)
│       ├── service/             Servicios + TokenService  (lógica de negocio)
│       ├── repository/          Acceso a datos (JdbcTemplate)
│       └── model/               Records con los datos que viajan
├── MascotasVete/                Frontend (Angular)
│   └── src/app/
│       ├── login-page/          Pantalla de login (RF15)
│       ├── publicaciones-page/  Listado y cambio de estado (RF13)
│       ├── alta-publicacion-page/  Formulario de alta (RF13)
│       ├── auth-resource.ts · publicacion-resource.ts · dominio-resource.ts
│       ├── sesion.ts            Contexto de la sesión
│       ├── auth-guard.ts        Protección de rutas
│       ├── auth-interceptor.ts  Agrega el token a cada llamada y maneja el 401
│       └── app.routes.ts · app.config.ts
└── scripts SQL                  Creación de tablas, datos de prueba y procedimientos
```

## 4. Arquitectura

```
Angular  ──HTTP/JSON──▶  Resource  ──▶  Service  ──▶  Repository  ──JdbcTemplate──▶  SQL Server
(pantallas)             (REST)        (negocio)     (acceso a datos)                 (procedimientos)
```

- **Presentación:** Angular (frontend) y los `Resource` de Spring (entrada REST).
- **Lógica de negocio:** vive principalmente en los **procedimientos almacenados** de SQL Server, por indicación de la cátedra de mantener el backend lo más simple posible. Los `Service` quedan como una capa intermedia fina que mantiene la separación entre capas.
- **Acceso a datos:** cada `Repository` llama a un procedimiento almacenado con `JdbcTemplate`. No se usa JPA ni ORM.
- **Bajo acoplamiento:** cada capa solo conoce a la siguiente; los datos viajan en `records` simples.

## 5. Base de datos

Scripts, en el orden en que deben ejecutarse (todos sobre la base `CordobaMascotas`):

| Orden | Contenido |
|---|---|
| 1 | Creación de las 13 tablas del modelo lógico (la base CordobaMascotas debe existir). |
| 2 | Datos de prueba: 3 ciudadanos, 2 refugios, mascotas, características y publicaciones. |
| 3 | Procedimientos almacenados (tabla siguiente). Incluye pasar las contraseñas a hash SHA-256. |
| 4 | `FotosPublicaciones.sql`: Asigna fotos de prueba a las publicaciones. |

Usuario de la aplicación: se creó un login de SQL Server propio (`mascotas_app`) con rol `db_owner` sobre la base, en lugar de usar `sa`.

### Procedimientos almacenados

| Procedimiento | Qué hace |
|---|---|
| `sp_login(@cuil, @clave)` | Valida CUIL y contraseña (compara el hash SHA-256), exige que el ciudadano esté habilitado y devuelve sus datos junto con el refugio del que es responsable. Si no coincide, devuelve cero filas. |
| `sp_listar_publicaciones(@id_refugio)` | Devuelve las publicaciones del refugio con nombre, especie, sexo, edad aproximada (año actual menos año de nacimiento), raza, descripción, condiciones, foto, estado y fecha. |
| `sp_listar_dominio(@nom_rasgo)` | Devuelve los valores permitidos de un rasgo (para los desplegables de especie y raza). |
| `sp_alta_publicacion(...)` | En una **transacción**: crea la mascota, sus características (especie y raza) y la publicación asociada al refugio. Devuelve el número de publicación. |
| `sp_cambiar_estado(@nro_publicacion, @id_refugio, @nuevo_estado)` | Cambia el estado solo si la transición es válida y la publicación pertenece al refugio. Devuelve cuántas filas cambió (0 = operación no permitida). |

**Transiciones de estado permitidas:**

| Estado actual | Puede pasar a |
|---|---|
| ACTIVA | PAUSADA, FINALIZADA |
| PAUSADA | ACTIVA, FINALIZADA |
| FINALIZADA | (ninguno) |

## 6. Backend – servicios REST

Puerto `8080`. Todos los endpoints exigen un token JWT (`Authorization: Bearer <token>`), salvo el login. CORS habilitado solo para `http://localhost:4200` (`config/SecurityConfig`).

| Método | Ruta | Cuerpo / parámetros | Respuesta |
|---|---|---|---|
| `POST` | `/api/auth/login` | `{ "cuil", "clave" }` | `200` con `{ token, usuario }`; `401` si las credenciales son inválidas. |
| `GET` | `/api/publicaciones` | – | Lista de publicaciones del refugio del usuario autenticado. |
| `POST` | `/api/publicaciones` | `{ nombre, sexo, anioNacimiento, nroEspecie, nroRaza, caracteristicas, condicionAdopcion, foto }` | `201` con el número de la publicación creada. |
| `PATCH` | `/api/publicaciones/{nro}/estado` | `{ "estado" }` | `200` si se cambió; `409` si la operación no corresponde. |
| `GET` | `/api/dominios/{rasgo}` | `Especie` o la raza correspondiente | Lista de `{ nroValorDominio, nombre }`. |

La **foto** viaja dentro del JSON codificada en base64 (Spring la convierte a `byte[]`) y se guarda en una columna `VARBINARY(MAX)`.

## 7. Frontend – Angular

| Pantalla | Ruta | Descripción |
|---|---|---|
| Login | `/login` | Formulario reactivo con validación del CUIL (11 dígitos). Muestra un mensaje si las credenciales son incorrectas. |
| Publicaciones | `/publicaciones` | Tarjetas con foto y datos de cada mascota, estado con color y acciones según el estado actual. Botón **Salir**. |
| Nueva publicación | `/publicaciones/nueva` | Formulario con validaciones, desplegables de especie y raza, carga de foto con vista previa (máximo 2 MB). |

- **Sesión:** `Sesion` guarda el token y el usuario autenticado en `sessionStorage` (se pierde al cerrar la pestaña) y considera cerrada la sesión si el token venció.
- **Interceptor:** `authInterceptor` agrega `Authorization: Bearer <token>` a cada llamada a la API. Si el servidor responde `401` (token vencido o inválido), cierra la sesión y redirige a `/login`.
- **Guard:** `authGuard` impide entrar a `/publicaciones` y `/publicaciones/nueva` sin sesión válida y redirige a `/login`. Es solo una ayuda de navegación: la seguridad real la aplica el servidor.
- **Acciones según el estado:** Activa muestra *Pausar* y *Finalizar*; Pausada muestra *Activar* y *Finalizar*; Finalizada no muestra acciones.
- **Responsive:** grilla de Bootstrap (1 columna en celular, 2 en tablet, 3 en escritorio).
- **Recursos:** servicios con sufijo `-resource` y la URL base en `environments`.

## 8. Seguridad

| Aspecto | Cómo se resuelve |
|---|---|
| Autenticación | `sp_login` valida CUIL y contraseña (hash SHA-256) y que el ciudadano esté habilitado. Si es correcto, el backend emite un **JWT firmado (HS256)** con vida de 1 hora. |
| Contenido del token | `sub` (id del ciudadano), `idRefugio`, emisor (`mascotas-backend`), fecha de emisión y de vencimiento. |
| Validación | Spring Security (resource server) verifica en **cada llamada** la firma, el vencimiento y el emisor. Sin token o con un token adulterado o vencido, responde `401`. |
| Autorización | El refugio se toma **del token**, nunca del cliente: un usuario solo puede listar, crear y cambiar publicaciones de su propio refugio, aunque intente enviar otro `idRefugio`. |
| Clave de firma | Está en `src/main/resources/secrets.properties`, excluido de git (`.gitignore`), igual que las credenciales de la base. Debe tener al menos 32 caracteres. |
| Sesión | Sin estado en el servidor (stateless). CSRF deshabilitado porque no se usan cookies de sesión: el token viaja en el encabezado `Authorization`. |
| CORS | Solo se acepta el origen `http://localhost:4200`. |
| Base de datos | La aplicación usa un login propio (`mascotas_app`), no `sa`. |

## 9. Cómo ejecutar

1. Ejecutar en SQL Server los scripts de la sección 5, en orden.
2. En `application.properties` del backend deben estar la URL de la base y la importación de secretos:

   ```properties
   spring.datasource.url=jdbc:sqlserver://localhost:1433;databaseName=CordobaMascotas;encrypt=false
   spring.config.import=optional:classpath:secrets.properties
   ```

   Y crear `src/main/resources/secrets.properties` (no se sube a git) con las credenciales y la clave de firma:

   ```properties
   app.jwt.secret=<clave aleatoria de al menos 32 caracteres>
   spring.datasource.username=<usuario>
   spring.datasource.password=<contraseña>
   ```

3. Levantar el backend (ejecutar `DemoApplication`). Debe quedar escuchando en `http://localhost:8080`.
4. En la carpeta del frontend: `npm install` y `ng serve`. Abrir `http://localhost:4200`.

### Usuarios de prueba (contraseña: `clave123`)

| CUIL | Usuario | Resultado |
|---|---|---|
| `27301234568` | Laura Gómez (refugio Patitas Felices) | Ingresa |
| `20285678901` | Martín Pérez (refugio Hogar Animal Córdoba) | Ingresa |
| `27334455667` | Ana Suárez | No ingresa (no habilitada) |

## 10. Decisiones de diseño

- **Lógica en SQL:** por indicación de la cátedra, las reglas (validar el login, calcular la edad, permitir o no un cambio de estado) están en procedimientos almacenados y el backend solo los invoca.
- **JWT para mantener el contexto de sesión:** el servidor emite un token firmado al autenticar y lo valida en cada llamada, de modo que el refugio y la identidad del usuario no dependen de lo que envíe el cliente.
- **Contraseñas con hash:** se guarda el hash SHA-256 y el procedimiento de login lo compara, de modo que no hay contraseñas en texto plano. Es una simplificación: un sistema real usaría un algoritmo con sal (por ejemplo, BCrypt).
- **Foto en la base de datos:** la consigna pide persistir la información de publicaciones en SQL Server; guardarla en `VARBINARY(MAX)` evita depender de un almacenamiento de archivos aparte.
- **Especie y raza:** se guardan como características de la mascota mediante `rasgos_mascotas` y `dominio_rasgos_mascotas`, con un rasgo `Especie` y un rasgo `Raza`. El modelo de la cátedra no relaciona razas con especies, y como no se permite modificarlo, el desplegable de razas muestra todas las razas sin filtrar por la especie elegida.
- **Sin edición:** no se implementó edición de publicaciones, tal como indica la consigna.

## 11. Limitaciones conocidas

- El hash de contraseña es SHA-256 **sin sal** (la lógica de login está en SQL Server, por indicación de la cátedra).
- No hay bloqueo por intentos fallidos de login ni renovación (refresh) del token: al vencer, el usuario vuelve a ingresar.
- El token se guarda en `sessionStorage`, accesible por JavaScript de la propia página.
- No se usa HTTPS (entorno de desarrollo local).
- Al dar de alta, la raza no se filtra según la especie (limitación del modelo, que no relaciona ambas).
- CORS está limitado a `http://localhost:4200` (entorno de desarrollo).
- La sesión se pierde al cerrar la pestaña del navegador.
- El número de registro y los códigos se asignan con `IDENTITY`, por lo que pueden quedar saltos de numeración si un alta falla y se deshace.
