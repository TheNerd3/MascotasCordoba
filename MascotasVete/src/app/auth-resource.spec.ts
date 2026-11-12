import { TestBed } from '@angular/core/testing';
import { AuthResource } from './auth-resource';

describe('AuthResource', () => {
  let service: AuthResource;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    service = TestBed.inject(AuthResource);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});
