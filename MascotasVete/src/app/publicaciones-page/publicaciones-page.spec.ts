import { ComponentFixture, TestBed } from '@angular/core/testing';
import { PublicacionesPage } from './publicaciones-page';

describe('PublicacionesPage', () => {
  let component: PublicacionesPage;
  let fixture: ComponentFixture<PublicacionesPage>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [PublicacionesPage],
    }).compileComponents();

    fixture = TestBed.createComponent(PublicacionesPage);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
