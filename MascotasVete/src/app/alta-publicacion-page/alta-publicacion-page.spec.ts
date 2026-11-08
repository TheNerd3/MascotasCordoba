import { ComponentFixture, TestBed } from '@angular/core/testing';
import { AltaPublicacionPage } from './alta-publicacion-page';

describe('AltaPublicacionPage', () => {
  let component: AltaPublicacionPage;
  let fixture: ComponentFixture<AltaPublicacionPage>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [AltaPublicacionPage],
    }).compileComponents();

    fixture = TestBed.createComponent(AltaPublicacionPage);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
