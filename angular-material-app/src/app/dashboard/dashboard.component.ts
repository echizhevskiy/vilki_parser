import {Component} from '@angular/core';
import { BetService } from './dashboard.service';

@Component({
  selector: 'app-dashboard',
  templateUrl: './dashboard.component.html',
  styleUrls: ['./dashboard.component.css']
})
export class DashboardComponent {
  displayedColumns = ['data', 'duel', 'match', 'total', 'parimatch', 'leon'];
  records = [];
  constructor(private myBetService: BetService) { }

  ngOnInit() {
    this.myBetService.getBets().subscribe(data => {
      this.records = data.bets;
    });
  }

  checkfortotal(data) {
    for (let i of data) {
      if (data[i]) {}
    }
  }
}
