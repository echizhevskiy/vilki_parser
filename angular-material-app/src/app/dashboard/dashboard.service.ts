import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';

interface MyData {
    bets: Array<string>;
}

@Injectable({
    providedIn: 'root'
})
export class BetService {
  constructor(private http: HttpClient) { }

  getBets() {
    return this.http.get<MyData>('http://localhost:3000/bet');
  }
}
