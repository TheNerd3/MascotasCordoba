import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../environments/environment';

export interface Publicacion {
  nroPublicacion: number;
  nombre: string;
  especie: string;
  sexo: string;
  edadAproximada: number;
  raza: string;
  caracteristicas: string;
  condicionAdopcion: string;
  foto: string;
  estado: string;
  fecha: string;
}

export interface AltaPublicacion {
  idRefugio: number;
  nombre: string;
  sexo: string;
  anioNacimiento: number;
  nroEspecie: number;
  nroRaza: number;
  caracteristicas: string;
  condicionAdopcion: string;
  foto: string;
}

@Injectable({ providedIn: 'root' })
export class PublicacionResource {

  private readonly _baseUrl = `${environment.apiUrl}/publicaciones`;

  constructor(private _http: HttpClient) { }

  listar(): Observable<Publicacion[]> {
    return this._http.get<Publicacion[]>(this._baseUrl);
  }

  cambiarEstado(nroPublicacion: number, estado: string): Observable<void> {
    return this._http.patch<void>(`${this._baseUrl}/${nroPublicacion}/estado`, { estado });
  }

  alta(datos: AltaPublicacion): Observable<number> {
    return this._http.post<number>(this._baseUrl, datos);
  }
}