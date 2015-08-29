//= require jquery-ui-1.9.2.custom.min
//= require jquery.timepicker
//= require bootstrap.min
//= require jquery.dcjqaccordion.2.7
//= require jquery.scrollTo.min
//= require jquery.nicescroll
//= require underscore.js
//= require raphael-min
//= require morris-0.4.3.min
//= require common-scripts

var monthNames = ["January", "February", "March", "April", "May", "June",
  "July", "August", "September", "October", "November", "December"]

$("#datepicker").datepicker({dateFormat: 'dd/mm/yy',inline: true});  

var week_options = {
    element: 'testchart',
    data: [],
    xkey: 'time_unit',
    ykeys: ['Wh'],
    labels: ['Total'],
    barColors:['#F44336'],
    xLabelAngle: 60,
    postUnits: " Wh",
    resize: true
  };

var month_options = {
    element: 'testchart',
    data: [],
    xkey: 'time_unit',
    ykeys: ['Wh'],
    labels: ['Total'],
    barColors:['#F44336'],
    xLabelFormat: function(d){
      date = new Date(d.label*1000);
      return date.getDate()+'/'+(date.getMonth()+1); 
    },
    dateFormat: function (x) { return new Date(x.label*1000); },
    xLabelAngle: 60,
    postUnits: " Wh"
  };

var year_options = {
    element: 'testchart',
    data: [],
    xkey: 'time_unit',
    ykeys: ['Wh'],
    labels: ['Total'],
    barColors:['#F44336'],
    xLabelAngle: 60,
    postUnits: " Wh"
  };

  var current_chart = null;
  var date = $( "#datepicker" ).datepicker( "getDate" ) || new Date();
  date.setHours(0,0,0,0);


$(document).ready(function(){
 $("#testchart").addClass("loading");
 //Activates the first radio btn
 $("input:radio:first").attr('checked', true);
 //Retreaves active circuits 
var checked = $('input:checked');
// Get the data
  $.getJSON("/reports/sum_energy_week/"+ date, function(data) {
  var time_unit = []
  var clean_data = []
  for(var i = 0; i < data.length; i++){
      time_unit.push(data[i].time_unit)
    }
    time_unit = _.uniq(time_unit)
    console.log(data);
  for(var i = 0; i < time_unit.length; i++){
      var sum = 0
      for(var j = 0; j < data.length; j++){
          if(time_unit[i]==data[j].time_unit){
            sum += parseInt(data[j].wh) 
          }
      }
    clean_data.push({time_unit : time_unit[i], Wh : sum})  
  }
  $("#testchart").removeClass("loading");
  current_chart = Morris.Bar(week_options);
  current_chart.setData(clean_data);
  });
});

$("#reload").on("click", function(e){
  var checked = $('input:checked');
  var checks = [];
  var chart = $("input:radio[name=options]:checked").val();
  var date = $( "#datepicker" ).datepicker( "getDate" ) || new Date();
  date.setHours(0,0,0,0);

  for(var i = 1; i < checked.length; i++){
    checks.push(parseInt(checked[i].attributes[1].value))
  }
  
  $('svg').remove();
  $(".morris-hover.morris-default-style").remove();
  //After, adds the spinner for loading
  $("#testchart").addClass("loading");
  //Depending of the chart value, a url variable is assigned
  if (chart == "week") {
    url = "/reports/sum_energy_week/";
  } else if (chart == "month") {
    url = "/reports/sum_energy_month/";
  } else if (chart == "year") {
    url = "/reports/sum_energy_year/";
  }
  //With the url set, the data to be displeyed is searched, plus the circuit id wich cames form data("circuit")
  $.getJSON(url + date, function(data) {
    console.log(data);
    var time_unit = []
    var clean_data = []
    for(var i = 0; i < data.length; i++){
      time_unit.push(data[i].time_unit)
    }
    time_unit = _.uniq(time_unit)
    for(var i = 0; i < time_unit.length; i++){
      var sum = 0
      for(var j = 0; j < data.length; j++){
          if(time_unit[i]==data[j].time_unit  && _.contains(checks,data[j].id)){
            sum += parseInt(data[j].wh) 
          }
      }
    clean_data.push({time_unit : time_unit[i], Wh : sum})  
  }
     current_chart = Morris.Bar(week_options);
     current_chart.setData(clean_data);
     $("#testchart").removeClass("loading");
  });
  //This takes care of .active class for the navs
  $(this).parent().parent().find(".active").removeClass("active");
  $(this).parent().addClass("active");
  
})


