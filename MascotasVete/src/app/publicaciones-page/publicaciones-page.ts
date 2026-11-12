import { Component, inject, OnInit, signal } from '@angular/core';
import { Router, RouterLink } from '@angular/router';
import { Publicacion, PublicacionResource } from '../publicacion-resource';
import { Sesion } from '../sesion';

@Component({
  selector: 'app-publicaciones-page',
  imports: [RouterLink],
  templateUrl: './publicaciones-page.html',
  styleUrl: './publicaciones-page.css'
})
export class PublicacionesPage implements OnInit {

  private _sesion = inject(Sesion);
  private _resource = inject(PublicacionResource);
  private _router = inject(Router);

  usuario = this._sesion.obtener();
  publicaciones = signal<Publicacion[]>([]);
  error = signal('');

  ngOnInit(): void {
    this.cargar();
  }

  cargar(): void {
    if (!this.usuario) {
      this._router.navigate(['/login']);
      return;
    }
    this._resource.listar().subscribe({
      next: (lista) => this.publicaciones.set(lista),
      error: () => this.error.set('No se pudieron cargar las publicaciones.')
    });
  }

  cambiarEstado(publicacion: Publicacion, estado: string): void {
    this.error.set('');
    this._resource.cambiarEstado(publicacion.nroPublicacion, estado).subscribe({
      next: () => this.cargar(),
      error: () => this.error.set('La operación no está permitida para esta publicación.')
    });
  }

  salir(): void {
    this._sesion.cerrar();
    this._router.navigate(['/login']);
  }
}