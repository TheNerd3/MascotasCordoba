import { Injectable } from '@angular/core';
import { UsuarioSesion } from './auth-resource';

@Injectable({ providedIn: 'root' })
export class Sesion {

  private readonly _claveUsuario = 'usuario';
  private readonly _claveToken = 'token';

  guardar(token: string, usuario: UsuarioSesion): void {
    sessionStorage.setItem(this._claveToken, token);
    sessionStorage.setItem(this._claveUsuario, JSON.stringify(usuario));
  }

  obtener(): UsuarioSesion | null {
    const datos = sessionStorage.getItem(this._claveUsuario);
    return datos ? JSON.parse(datos) : null;
  }

  obtenerToken(): string | null {
    return sessionStorage.getItem(this._claveToken);
  }

  estaAutenticado(): boolean {
    const token = this.obtenerToken();
    return token !== null && this.obtener() !== null && !this.vencido(token);
  }

  cerrar(): void {
    sessionStorage.removeItem(this._claveToken);
    sessionStorage.removeItem(this._claveUsuario);
  }

  // Solo para mejorar la experiencia: la validación real la hace el servidor.
  private vencido(token: string): boolean {
    try {
      const payload = JSON.parse(atob(token.split('.')[1].replace(/-/g, '+').replace(/_/g, '/')));
      return payload.exp * 1000 <= Date.now();
    } catch {
      return true;
    }
  }
}