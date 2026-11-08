import { TestBed } from '@angular/core/testing';
import { PublicacionResource } from './publicacion-resource';

describe('PublicacionResource', () => {
  let service: PublicacionResource;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    service = TestBed.inject(PublicacionResource);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});
