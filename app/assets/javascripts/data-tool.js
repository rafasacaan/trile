//= require jquery-ui-1.9.2.custom.min
//= require bootstrap.min
//= require jquery.dcjqaccordion.2.7
//= require jquery.scrollTo.min
//= require jquery.nicescroll
//= require raphael-min
//= require morris-0.4.3.min
//= require common-scripts
//= require underscore.js


var monthNames = ["January", "February", "March", "April", "May", "June",
  "July", "August", "September", "October", "November", "December"];

var checks = $( ":checkbox" );

$("#datepicker").datepicker({dateFormat: 'dd/mm/yy',inline: true});

graph = {
    element: 'testchart',
    hideHover: 'auto',
    data: [],
    xkey: 'created_at',
    ykeys: [],
    labels: [],
    resize: false,
    lineColors: ["#00E676","#1E88E5","#FFB74D","#FF7043","#B2FF59","#40C4FF"],
    lineWidth: 2,
    fillOpacity: 0.03,
    pointSize: 3,
    resize: true,
    ymax: 'auto',
    dateFormat: function(date) {
          d = new Date(date);
          var hours = d.getHours();
          var minutes = "0" + d.getMinutes();
          var seconds = "0" + d.getSeconds();
          return d.getDate()+'/'+(d.getMonth()+1)+'/'+d.getFullYear()+' '+hours+':'+minutes.substr(-2);
    }
};
var testchart = Morris.Line(graph);

$(function() {
  
});

$("#circuit-table").change(function(e){
  var checkeds_raw =  _.filter(checks, function(check){ return check.checked; });
  var checkeds = _.map(checkeds_raw,function(checks){ return checks.id});
});

$("#datepicker").change(function(e) {
  //Get the date
  var date = $( "#datepicker" ).datepicker( "getDate" );
  var month = date.getMonth(); 
  $("#current_month").html(" Current month: " + monthNames[month]);
});