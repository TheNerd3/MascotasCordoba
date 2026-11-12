import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../environments/environment';

export interface Dominio {
  nroValorDominio: number;
  nombre: string;
}

@Injectable({ providedIn: 'root' })
export class DominioResource {

  private readonly _baseUrl = `${environment.apiUrl}/dominios`;

  constructor(private _http: HttpClient) { }

  listar(rasgo: string): Observable<Dominio[]> {
    return this._http.get<Dominio[]>(`${this._baseUrl}/${rasgo}`);
  }
}