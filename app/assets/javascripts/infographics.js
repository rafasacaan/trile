//= require jquery-ui-1.9.2.custom.min
//= require bootstrap.min
//= require jquery.dcjqaccordion.2.7
//= require jquery.scrollTo.min
//= require jquery.nicescroll
//= require raphael-min
//= require morris-0.4.3.min
//= require common-scripts

Morris.Donut({
  element: 'donut-example',
  data: [
    {value: 70, label: 'foo'},
    {value: 15, label: 'bar'},
    {value: 10, label: 'baz'},
    {value: 5, label: 'A really really long label'}
  ],
  backgroundColor: '#ccc',
  labelColor: '#060',
  colors: [
    '#0BA462',
    '#39B580',
    '#67C69D',
    '#95D7BB'
  ],
  formatter: function (x) { return x + "%"}
});
