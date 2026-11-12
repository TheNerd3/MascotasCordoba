package com.example.demo.resource;

import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.demo.model.AltaPublicacionRequest;
import com.example.demo.model.CambioEstadoRequest;
import com.example.demo.model.Publicacion;
import com.example.demo.service.PublicacionService;

@RestController
@RequestMapping("/api/publicaciones")
public class PublicacionResource {

    private final PublicacionService service;

    public PublicacionResource(PublicacionService service) {
        this.service = service;
    }

    private int refugioDe(Jwt jwt) {
        return ((Number) jwt.getClaim("idRefugio")).intValue();
    }

    @GetMapping
    public List<Publicacion> listar(@AuthenticationPrincipal Jwt jwt) {
        return service.listar(refugioDe(jwt));
    }

    @PostMapping
    public ResponseEntity<Integer> alta(@AuthenticationPrincipal Jwt jwt,
                                        @RequestBody AltaPublicacionRequest r) {
        AltaPublicacionRequest conRefugioDelToken = new AltaPublicacionRequest(
                refugioDe(jwt), r.nombre(), r.sexo(), r.anioNacimiento(),
                r.nroEspecie(), r.nroRaza(), r.caracteristicas(),
                r.condicionAdopcion(), r.foto());
        return ResponseEntity.status(HttpStatus.CREATED).body(service.alta(conRefugioDelToken));
    }

    @PatchMapping("/{nroPublicacion}/estado")
    public ResponseEntity<Void> cambiarEstado(@AuthenticationPrincipal Jwt jwt,
                                              @PathVariable int nroPublicacion,
                                              @RequestBody CambioEstadoRequest request) {
        boolean cambiado = service.cambiarEstado(nroPublicacion, refugioDe(jwt), request.estado());
        if (!cambiado) {
            return ResponseEntity.status(HttpStatus.CONFLICT).build();
        }
        return ResponseEntity.ok().build();
    }
}