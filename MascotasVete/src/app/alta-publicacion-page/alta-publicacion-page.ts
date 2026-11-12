import { Component, inject, OnInit, signal } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { Router } from '@angular/router';
import { Dominio, DominioResource } from '../dominio-resource';
import { PublicacionResource } from '../publicacion-resource';
import { Sesion } from '../sesion';

@Component({
  selector: 'app-alta-publicacion-page',
  imports: [ReactiveFormsModule],
  templateUrl: './alta-publicacion-page.html',
  styleUrl: './alta-publicacion-page.css'
})
export class AltaPublicacionPage implements OnInit {

  private _fb = inject(FormBuilder);
  private _dominios = inject(DominioResource);
  private _resource = inject(PublicacionResource);
  private _sesion = inject(Sesion);
  private _router = inject(Router);

  usuario = this._sesion.obtener();
  anioActual = new Date().getFullYear();

  especies = signal<Dominio[]>([]);
  razas = signal<Dominio[]>([]);
  fotoBase64 = signal('');
  fotoVista = signal('');
  error = signal('');
  guardando = signal(false);

  form = this._fb.nonNullable.group({
    nombre: ['', [Validators.required, Validators.maxLength(50)]],
    sexo: ['', Validators.required],
    anioNacimiento: [this.anioActual, [Validators.required, Validators.min(this.anioActual - 30), Validators.max(this.anioActual)]],
    nroEspecie: [0, Validators.min(1)],
    nroRaza: [0, Validators.min(1)],
    caracteristicas: ['', [Validators.required, Validators.maxLength(500)]],
    condicionAdopcion: ['', [Validators.required, Validators.maxLength(500)]]
  });

  ngOnInit(): void {
    if (!this.usuario) {
      this._router.navigate(['/login']);
      return;
    }
    this._dominios.listar('Especie').subscribe((lista) => this.especies.set(lista));
    this._dominios.listar('Raza').subscribe((lista) => this.razas.set(lista));
  }

  onFoto(evento: Event): void {
    const archivo = (evento.target as HTMLInputElement).files?.[0];
    if (!archivo) {
      return;
    }
    if (!archivo.type.startsWith('image/')) {
      this.error.set('El archivo debe ser una imagen.');
      return;
    }
    if (archivo.size > 2 * 1024 * 1024) {
      this.error.set('La foto no puede superar los 2 MB.');
      return;
    }
    this.error.set('');
    const lector = new FileReader();
    lector.onload = () => {
      const resultado = lector.result as string;
      this.fotoVista.set(resultado);
      this.fotoBase64.set(resultado.split(',')[1]);
    };
    lector.readAsDataURL(archivo);
  }

  guardar(): void {
    if (this.form.invalid || !this.fotoBase64()) {
      this.form.markAllAsTouched();
      if (!this.fotoBase64()) {
        this.error.set('Seleccioná una foto.');
      }
      return;
    }
    this.guardando.set(true);
    this.error.set('');
    const valores = this.form.getRawValue();

    this._resource.alta({
      idRefugio: this.usuario!.idRefugio,
      ...valores,
      foto: this.fotoBase64()
    }).subscribe({
      next: () => this._router.navigate(['/publicaciones']),
      error: () => {
        this.error.set('No se pudo guardar la publicación.');
        this.guardando.set(false);
      }
    });
  }

  cancelar(): void {
    this._router.navigate(['/publicaciones']);
  }
}