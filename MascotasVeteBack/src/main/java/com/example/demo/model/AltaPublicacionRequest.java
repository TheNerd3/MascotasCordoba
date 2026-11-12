package com.example.demo.model;

public record AltaPublicacionRequest(int idRefugio, String nombre, String sexo, int anioNacimiento,
                                     int nroEspecie, int nroRaza, String caracteristicas,
                                     String condicionAdopcion, byte[] foto) {
}