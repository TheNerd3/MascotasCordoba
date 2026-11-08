package com.example.demo.service;

import com.example.demo.model.Dominio;
import com.example.demo.repository.DominioRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class DominioService {

    private final DominioRepository repository;

    public DominioService(DominioRepository repository) {
        this.repository = repository;
    }

    public List<Dominio> listar(String rasgo) {
        return repository.listar(rasgo);
    }
}