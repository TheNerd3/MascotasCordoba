package com.example.demo.service;

import java.util.List;

import org.springframework.stereotype.Service;

import com.example.demo.model.AltaPublicacionRequest;
import com.example.demo.model.Publicacion;
import com.example.demo.repository.PublicacionRepository;

@Service
public class PublicacionService {

    private final PublicacionRepository repository;

    public PublicacionService(PublicacionRepository repository) {
        this.repository = repository;
    }

    public List<Publicacion> listar(int idRefugio) {
        return repository.listar(idRefugio);
    }

    public boolean cambiarEstado(int nroPublicacion, int idRefugio, String nuevoEstado) {
        return repository.cambiarEstado(nroPublicacion, idRefugio, nuevoEstado) > 0;
    }

    public int alta(AltaPublicacionRequest request) {
        return repository.alta(request);
    }
}