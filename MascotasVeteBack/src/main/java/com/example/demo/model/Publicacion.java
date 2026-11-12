package com.example.demo.model;

public record Publicacion(int nroPublicacion, String nombre, String especie, String sexo,
                          int edadAproximada, String raza, String caracteristicas,
                          String condicionAdopcion, byte[] foto, String estado, String fecha) {
}