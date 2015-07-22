//= require jquery-ui-1.9.2.custom.min
//= require bootstrap.min
//= require jquery.dcjqaccordion.2.7
//= require jquery.scrollTo.min
//= require jquery.nicescroll
//= require raphael-min
//= require morris-0.4.3.min
//= require common-scripts

/*
  This is where graph are drawn
  graph is an array with the option for the chart to be displayed
  testchart is a Morris object and its attributes will change deppending on the circuit and the tab cliked
*/

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
     return d.getDate()+'/'+(d.getMonth()+1)+'/'+d.getFullYear();
   },

};
  var current_chart = null;
  
  var month_options = {
    element: 'testchart',
    data: [],
    xkey: 'dt',
    ykeys: ['watts'],
    labels: [],
    barColors:['#F44336'],
    xLabelFormat: function(d){
      date = new Date(Date.parse(d.label));
      return date.getDate()+'/'+(date.getMonth()+1)+'/'+date.getFullYear()  
    },
    xLabels:"day"
  };

  var year_options = {
    element: 'testchart',
    data: [],
    xkey: 'dt',
    ykeys: ['watts'],
    labels: [],
    barColors:['#F44336'],
  };

$.getJSON("/reports/today_measures/" + parseInt($("#testchart").data("circuit")), function(data) {
  $("#testchart").removeClass("loading");
  $.getJSON("/reports/circuit_type/" + parseInt($("#testchart").data("circuit")), function(data) {
    area_options.labels.push(data);
  });
  current_chart = Morris.Area(area_options);
  current_chart.setData(data);
});

$("#datepicker").datepicker({dateFormat: 'dd/mm/yy',inline: true});

$("a.nav-tab-action").click(function(e) {
  //Remove from DOM the elements created by morris before, so they don't crush on each click event
  $('svg').remove();
  $(".morris-hover.morris-default-style").remove();  
  //After, adds the spinner for loading
  $("#testchart").addClass("loading");
  
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

  //With the url set, the data to be displeyed is searched, plus the circuit id wich cames form data("circuit")
  $.getJSON(url + parseInt($("#testchart").data("circuit")), function(data) {
    //Removes the spinning class
    $("#testchart").removeClass("loading");
    //If the chart is month or year then,
    if (chart == "month") {
      $.getJSON("/reports/circuit_type/" + parseInt($("#testchart").data("circuit")), function(data) {
        month_options.labels = [];
        month_options.labels.push(data);
      });
      current_chart = Morris.Bar(month_options);
      current_chart.setData(data);
    } else if (chart == "year"){
      $.getJSON("/reports/circuit_type/" + parseInt($("#testchart").data("circuit")), function(data) {
        year_options.labels = [];
        year_options.labels.push(data);
      });
      current_chart = Morris.Bar(year_options);
      current_chart.setData(data);
    } else {
      $.getJSON("/reports/circuit_type/" + parseInt($("#testchart").data("circuit")), function(data) {
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

//This is triggered when a change is made on the datepicker calendar
$("#datepicker").change(function(e) {
  //Remove from DOM the elements created by morris before, so they don't crush on each click event
  $('svg').remove();
  $(".morris-hover.morris-default-style").remove();
  //Get the date
  date = $( "#datepicker" ).datepicker( "getDate" );
  $("#testchart").addClass("loading");
  //Make de AJAX call to the server
  $.getJSON("/reports/specific_date_measures/" + parseInt($("#testchart").data("circuit")) + "/" + date, function(data) {
    //Remove the spinnig wheel  
    $("#testchart").removeClass("loading");
    //AJAX call for labels
   $.getJSON("/reports/circuit_type/" + parseInt($("#testchart").data("circuit")), function(data) {
      area_options.labels = [];
      area_options.labels.push(data);
    });
    //Set the new data
    current_chart = Morris.Area(area_options);
    current_chart.setData(data);
  });
 //Remove active class from tabs  
  $("a.nav-tab-action").parent().parent().find(".active").removeClass("active");
 });
  
