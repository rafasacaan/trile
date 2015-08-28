//= require jquery-ui-1.9.2.custom.min
//= require bootstrap.min
//= require jquery.dcjqaccordion.2.7
//= require jquery.scrollTo.min
//= require jquery.nicescroll
//= require raphael-min
//= require morris-0.4.3.min
//= require underscore.js
//= require common-scripts


var monthNames = ["January", "February", "March", "April", "May", "June",
  "July", "August", "September", "October", "November", "December"]

$("#datepicker").datepicker({dateFormat: 'dd/mm/yy',inline: true});  

var options = {
  element: 'donut-example',
  data: [],
  backgroundColor: '#ccc',
  labelColor: '#060',
  colors: [
    '#5cb85c',
    '#5bc0de',
    '#f0ad4e',
    '#d9534f',
    '#5cb85c',
    '#5bc0de',
    '#f0ad4e',
    '#d9534f'
  ],
  formatter: function (x) { return x + "%"}
};

var current_chart = null;

$(function(){
  setchart();
});

function setchart(date){
  var date = date || new Date();
  date.setHours(0,0,0,0);
  var type = $("input:radio[name=options]:checked").val();
  $.getJSON("/reports/donuts/"+date +"/" +type, function(data) {
    var sum = 0;
    var datos = [];
    for (var i = 0; i < data.length; i++){
      sum += data[i].wattshora
    }
    options.data = [];
    for (var i = 0; i < data.length; i++){
      data[i].part = Math.round((data[i].wattshora/sum*100)*100)/100; 
      options.data.push ({value : data[i].part, label : data[i].descr });
      $("#"+data[i].ids).width((data[i].part)+"%");
      $("#"+data[i].ids).html((data[i].part)+"%");
      $("#"+data[i].ids).css('backgroundColor', options.colors[i]);
      $("#"+data[i].ids+"-value").html("$" + numberWithDots(Math.round(data[i].wattshora*0.09*1)/1));
    }
     current_chart = Morris.Donut(options);
    });
};

$("#reload").click(function(e){
  //Remove from DOM the elements created by morris before, so they don't crush on each click event
  $('svg').remove();
  $(".morris-hover.morris-default-style").remove(); 
  var date = $( "#datepicker" ).datepicker( "getDate" ); 
  setchart(date);
})

function numberWithDots(x) {
    return x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
}