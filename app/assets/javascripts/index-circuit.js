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

var area_options = {
  element: 'testchart',
  data: [],
  xkey: 'created_at',
  ykeys: ['watts'],
  labels: [],
  lineColors: ['#00E676'],
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
  },
   xLabelFormat:function(date){
      d = new Date(date);
     var hours = d.getHours();
     var minutes = "0" + d.getMinutes();
     var seconds = "0" + d.getSeconds();
     return hours +':'+ minutes.substr(-2);
   },
   postUnits: " W",
   smooth: false
};

var area_options_2 = {
  element: 'testchart2',
  data: [],
  xkey: 'created_at',
  ykeys: ['watts'],
  labels: [],
  lineColors: ['#00E676'],
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
  },
   xLabelFormat:function(date){
      d = new Date(date);
     var hours = d.getHours();
     var minutes = "0" + d.getMinutes();
     var seconds = "0" + d.getSeconds();
     return hours +':'+ minutes.substr(-2);
   },
   postUnits: " W",
   smooth: false
};

  var month_options = {
    element: 'testchart3',
    data: [],
    xkey: 'dt',
    ykeys: ['watts'],
    labels: [],
    barColors:['#F44336'],
    xLabelFormat: function(d){
      date = new Date(d.label*1000);
      return date.getDate()+'/'+(date.getMonth()+1); 
    },
    dateFormat: function (x) { return new Date(x.label*1000); },
    xLabelAngle: 60,
    postUnits: " Wh"
  };

  var week_options = {
    element: 'testchart3',
    data: [],
    xkey: 'hours',
    ykeys: ['watts'],
    labels: [],
    barColors:['#F44336'],
    xLabelAngle: 60,
    postUnits: " Wh",
    resize: true
  };

  var year_options = {
    element: 'testchart3',
    data: [],
    xkey: 'dt',
    ykeys: ['watts'],
    labels: [],
    barColors:['#F44336'],
    xLabelAngle: 60,
    postUnits: " Wh"
  };

  var current_chart = null;
  var current_chart_2 = null;
  date = $( "#datepicker" ).datepicker( "getDate" ) || new Date();
  date.setHours(0,0,0,0);


$(document).ready(function(){
 $("input:radio:first").attr('checked', true);
 $("#datepicker").datepicker({dateFormat: 'dd/mm/yy',inline: true});  
 $("#datepicker2").datepicker({dateFormat: 'dd/mm/yy',inline: true});  

var checked= document.querySelector('input[name="circuits"]:checked').value;

 $("#testchart").attr("data-circuit", checked);
 $("#testchart2").attr("data-circuit", checked);
 $("#testchart3").attr("data-circuit", checked);

  $.getJSON("/reports/today_measures/" + parseInt($("#testchart").data("circuit"))+"/"+date, function(data) {
  $("#testchart").removeClass("loading");
  $.getJSON("/reports/circuit_type/" + parseInt($("#testchart").data("circuit")), function(data) {
    area_options.labels.push(data);
  	area_options_2.labels.push(data);
  });
  var filters = _.find(data, function(d){ return d.created_at > 0 
  });
  current_chart = Morris.Area(area_options);
  current_chart.setData(data);
  current_chart = Morris.Area(area_options_2);
  current_chart.setData(data);
  });
});

$("a.nav-tab-action").click(function(e) {
  //Remove from DOM the elements created by morris before, so they don't crush on each click event
  $('svg').remove();
  $(".morris-hover.morris-default-style").remove();  
  //After, adds the spinner for loading
  $("#testchart3").addClass("loading");
  chart = $(this).data("chart");
  //Depending of the chart value, a url variable is assigned
  if (chart == "day") {
    url = "/reports/today_measures/";
  } else if (chart == "week") {
    url = "/reports/week_measures/";
  } else if (chart == "month") {
    url = "/reports/month_measures/";
  } else if (chart == "year") {
    url = "/reports/year_measures/";
  }

  date = $( "#datepicker" ).datepicker( "getDate" ) || new Date();
  date.setHours(0,0,0,0);
  //With the url set, the data to be displeyed is searched, plus the circuit id wich cames form data("circuit")
  $.getJSON(url + parseInt($("#testchart3").data("circuit")) +"/"+date, function(data) {
    //Removes the spinning class
    $("#testchart").removeClass("loading");
    //If the chart is month or year then,
    if (chart == "month") {
       $.getJSON("/reports/circuit_type/" + parseInt($("#testchart3").data("circuit")) , function(data) {
        month_options.labels = [];
        month_options.labels.push(data);
      });
      current_chart = Morris.Bar(month_options);
      current_chart.setData(data);
    } else if (chart == "year"){
      $.getJSON("/reports/circuit_type/" + parseInt($("#testchart3").data("circuit")), function(data) {
        year_options.labels = [];
        year_options.labels.push(data);
      });
      current_chart = Morris.Bar(year_options);
      current_chart.setData(data);
    } else if (chart == "week"){
      $.getJSON("/reports/circuit_type/" + parseInt($("#testchart3").data("circuit")), function(data) {
        year_options.labels = [];
        year_options.labels.push(data);
      });
      current_chart = Morris.Bar(week_options);
      current_chart.setData(data);
    } else {
      $.getJSON("/reports/circuit_type/" + parseInt($("#testchart3").data("circuit")), function(data) {
        area_options.labels = [];
        area_options.labels.push(data);
      });
      current_chart = Morris.Area(area_options);
      current_chart.setData(data);
  }});
  //This takes care of .active class for the navs
  $(this).parent().parent().find(".active").removeClass("active");
  $(this).parent().addClass("active");
});//end click









