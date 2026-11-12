import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../environments/environment';

export interface UsuarioSesion {
  idCiudadano: number;
  apellido: string;
  nombre: string;
  idRefugio: number;
  razonSocial: string;
}

export interface LoginResponse {
  token: string;
  usuario: UsuarioSesion;
}

@Injectable({ providedIn: 'root' })
export class AuthResource {

  private readonly _baseUrl = `${environment.apiUrl}/auth`;

  constructor(private _http: HttpClient) { }

  login(cuil: string, clave: string): Observable<LoginResponse> {
    return this._http.post<LoginResponse>(`${this._baseUrl}/login`, { cuil, clave });
  }
}