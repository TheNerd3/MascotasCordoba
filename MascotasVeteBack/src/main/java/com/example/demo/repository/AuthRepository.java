package com.example.demo.repository;

import com.example.demo.model.UsuarioSesion;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public class AuthRepository {

    private final JdbcTemplate jdbc;

    public AuthRepository(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    public UsuarioSesion login(String cuil, String clave) {
        List<UsuarioSesion> resultado = jdbc.query(
                "EXEC sp_login ?, ?",
                (rs, i) -> new UsuarioSesion(
                        rs.getInt("id_ciudadano"),
                        rs.getString("apellido"),
                        rs.getString("nombre"),
                        rs.getInt("id_refugio"),
                        rs.getString("razon_social")),
                cuil, clave);
        return resultado.isEmpty() ? null : resultado.get(0);
    }
}