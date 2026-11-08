import { Routes } from '@angular/router';
import { LoginPage } from './login-page/login-page';
import { PublicacionesPage } from './publicaciones-page/publicaciones-page';
import { AltaPublicacionPage } from './alta-publicacion-page/alta-publicacion-page';
import { authGuard } from './auth-guard';

export const routes: Routes = [
  { path: 'login', component: LoginPage },
  { path: 'publicaciones', component: PublicacionesPage, canActivate: [authGuard] },
  { path: 'publicaciones/nueva', component: AltaPublicacionPage, canActivate: [authGuard] },
  { path: '', redirectTo: 'login', pathMatch: 'full' },
  { path: '**', redirectTo: 'login' },
];
