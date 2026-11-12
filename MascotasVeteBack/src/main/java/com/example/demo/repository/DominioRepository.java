package com.example.demo.repository;

import java.util.List;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import com.example.demo.model.Dominio;

@Repository
public class DominioRepository {

    private final JdbcTemplate jdbc;

    public DominioRepository(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    public List<Dominio> listar(String rasgo) {
        return jdbc.query(
                "EXEC sp_listar_dominio ?",
                (rs, i) -> new Dominio(rs.getInt("nro_valor_dominio"), rs.getString("nom_valor_dominio")),
                rasgo);
    }
}