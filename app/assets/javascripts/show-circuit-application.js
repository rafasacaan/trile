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

var graph, testchart;

graph = {
  element: 'testchart',
  hideHover: 'auto',
  data: [],
  xkey: 'created_at',
  ykeys: ['watts'],
  labels: [],
  resize: false,
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
          }
};

testchart = Morris.Area(graph);

//This function displays the initial graph (today_measures)
$(document).ready(function() {
    $.getJSON("/reports/today_measures/" + parseInt($("#testchart").data("circuit")), function(data) {
    $("#testchart").removeClass("loading");
    testchart.setData(data);
  });

//format date 

    var today = new Date();
    var dd = today.getDate();
    var mm = today.getMonth()+1; //January is 0!
    var yyyy = today.getFullYear();
    
    if(dd<10){
        dd='0'+dd
    } 
    if(mm<10){
        mm='0'+mm
    } 
    var today = dd+'/'+mm+'/'+yyyy;

  $("#datepicker").val(today); 
  $("#datepicker").datepicker({
                                dateFormat: 'dd/mm/yy',
                                inline: true
                              });

  //Needs Refactoring. This is piece of code is called 3 times in this page
  $.getJSON("/reports/circuit_type/" + parseInt($("#testchart").data("circuit")), function(data) {
    graph.labels.push(data);
  });
});
//Fin del ready

//This function takes the element "a.nav-tab-action" when is clicked and grabs the data element value, which
//can be day, week, month or year and assigns that value to the variable chart. See show.html.erb
$("a.nav-tab-action").click(function(e) {
  //sets the labels of the graph
  $.getJSON("/reports/circuit_type/" + parseInt($("#testchart").data("circuit")), function(data) {
    graph.labels.push(data);
  });
  //This delete the current graph
  data = []
  testchart.setData(data);
  //This adds the spinnig
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

  e.preventDefault();  

  //With the url set, the data to be displeyed is searched, plus the circuit id wich cames form data("circuit")
  $.getJSON(url + parseInt($("#testchart").data("circuit")), function(data) {
    //Removes the spinning class
    $("#testchart").removeClass("loading");
    testchart.setData(data);
  });

  //This takes care of .active class fot the navs
  $(this).parent().parent().find(".active").removeClass("active");
  $(this).parent().addClass("active");
});//end click

//This is triggered when a change is made on the datepicker calendar
$("#datepicker").change(function(e) {
  //Get the date
  date = $( "#datepicker" ).datepicker( "getDate" );
  //Set data to emptu array
  data = []
  //Clear the curent data with empty array
  testchart.setData(data);
  //Add css class with the spinning wheel
  $("#testchart").addClass("loading");
  //Make de AJAX call to the server
  $.getJSON("/reports/specific_date_measures/" + parseInt($("#testchart").data("circuit")) + "/" + date, function(data) {
  //Set the new data
    testchart.setData(data);
  //Remove the spinnig wheel  
    $("#testchart").removeClass("loading");
  });
  //AJAX call for labels
  $.getJSON("/reports/circuit_type/" + parseInt($("#testchart").data("circuit")), function(data) {
    graph.labels.push(data);
  });
});

