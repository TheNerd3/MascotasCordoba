import { TestBed } from '@angular/core/testing';
import { DominioResource } from './dominio-resource';

describe('DominioResource', () => {
  let service: DominioResource;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    service = TestBed.inject(DominioResource);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});
