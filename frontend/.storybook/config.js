import { configure } from '@storybook/angular';

function loadStories() {
  require('../src/app/table/table.component.ts');
 // require('../src/app/table/table.component.css');
  // You can require as many stories as you need.
}

configure(loadStories, module);

