package com.example.demo.service;

import com.example.demo.model.UsuarioSesion;
import com.example.demo.repository.AuthRepository;
import org.springframework.stereotype.Service;

@Service
public class AuthService {

    private final AuthRepository repository;

    public AuthService(AuthRepository repository) {
        this.repository = repository;
    }

    public UsuarioSesion login(String cuil, String clave) {
        return repository.login(cuil, clave);
    }
}