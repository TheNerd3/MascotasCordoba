package com.example.demo.resource;

import java.util.List;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.demo.model.Dominio;
import com.example.demo.service.DominioService;

@RestController
@RequestMapping("/api/dominios")
public class DominioResource {

    private final DominioService service;

    public DominioResource(DominioService service) {
        this.service = service;
    }

    @GetMapping("/{rasgo}")
    public List<Dominio> listar(@PathVariable String rasgo) {
        return service.listar(rasgo);
    }
}