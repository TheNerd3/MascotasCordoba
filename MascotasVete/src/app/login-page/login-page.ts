import { Component, inject } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { Router } from '@angular/router';
import { AuthResource } from '../auth-resource';
import { Sesion } from '../sesion';

@Component({
  selector: 'app-login-page',
  imports: [ReactiveFormsModule],
  templateUrl: './login-page.html',
  styleUrl: './login-page.css',
})
export class LoginPage {
  private _fb = inject(FormBuilder);
  private _auth = inject(AuthResource);
  private _sesion = inject(Sesion);
  private _router = inject(Router);

  error = '';
  cargando = false;

  form = this._fb.nonNullable.group({
    cuil: ['', [Validators.required, Validators.pattern(/^\d{11}$/)]],
    clave: ['', Validators.required],
  });

  ingresar(): void {
    if (this.form.invalid) {
      this.form.markAllAsTouched();
      return;
    }
    this.cargando = true;
    this.error = '';
    const { cuil, clave } = this.form.getRawValue();

    this._auth.login(cuil, clave).subscribe({
      next: (respuesta) => {
        this._sesion.guardar(respuesta.token, respuesta.usuario);
        this._router.navigate(['/publicaciones']);
      },
      error: () => {
        this.error = 'CUIL o contraseña incorrectos.';
        this.cargando = false;
      },
    });
  }
}
