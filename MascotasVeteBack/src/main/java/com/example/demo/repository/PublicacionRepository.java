package com.example.demo.repository;

import java.util.List;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import com.example.demo.model.AltaPublicacionRequest;
import com.example.demo.model.Publicacion;

@Repository
public class PublicacionRepository {

    private final JdbcTemplate jdbc;

    public PublicacionRepository(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    public List<Publicacion> listar(int idRefugio) {
        return jdbc.query(
                "EXEC sp_listar_publicaciones ?",
                (rs, i) -> new Publicacion(
                        rs.getInt("nro_publicacion"),
                        rs.getString("nombre"),
                        rs.getString("especie"),
                        rs.getString("sexo"),
                        rs.getInt("edad_aproximada"),
                        rs.getString("raza"),
                        rs.getString("caracteristicas_mascota"),
                        rs.getString("condicion_adopcion"),
                        rs.getBytes("foto"),
                        rs.getString("estado_publicacion"),
                        rs.getString("fecha_publicacion")),
                idRefugio);
    }

    public int cambiarEstado(int nroPublicacion, int idRefugio, String nuevoEstado) {
        Integer filas = jdbc.queryForObject(
                "EXEC sp_cambiar_estado ?, ?, ?",
                Integer.class,
                nroPublicacion, idRefugio, nuevoEstado);
        return filas == null ? 0 : filas;
    }

    public int alta(AltaPublicacionRequest r) {
        Integer nro = jdbc.queryForObject(
                "EXEC sp_alta_publicacion ?, ?, ?, ?, ?, ?, ?, ?, ?",
                Integer.class,
                r.idRefugio(), r.nombre(), r.sexo(), r.anioNacimiento(),
                r.nroEspecie(), r.nroRaza(), r.caracteristicas(),
                r.condicionAdopcion(), r.foto());
        return nro == null ? 0 : nro;
    }
}