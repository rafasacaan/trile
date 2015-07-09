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

//CONFIG VALUES//
var graph_options, testchart, bargraph, graph, chart;

graph_options = { element: 'testchart', data: [], xkey: 'created_at', ykeys: ['watts'], labels: [], resize: false,
                  lineColors: ['#00E676'], lineWidth: 2, fillOpacity: 0.03, pointSize: 3, resize: true, ymax: 'auto',
                  dateFormat: function(date) {
                          d = new Date(date);
                          var hours = d.getHours();
                          var minutes = "0" + d.getMinutes();
                          var seconds = "0" + d.getSeconds();
                          return d.getDate()+'/'+(d.getMonth()+1)+'/'+d.getFullYear()+' '+hours+':'+minutes.substr(-2); 
                }};

testchart = Morris.Area(graph_options);
//barchart = Morris.Bar(graph_options);
//END CONFIG//

    //This code block displays the initial graph (today_measures) when document is ready
    $(function() {
        $.getJSON("/reports/today_measures/" + parseInt($("#testchart").data("circuit")), function(data) {
        $("#testchart").removeClass("loading");
        graph = testchart;
        graph.setData(data);
      });
    //Datepicker formater
      $("#datepicker").datepicker({dateFormat: 'dd/mm/yy',inline: true});
    //Labels are set in this line into the graph_options  
      $.getJSON("/reports/circuit_type/" + parseInt($("#testchart").data("circuit")), function(data) {
        //graph_options.labels.push(data);
      });
    });//End ready function

//This function takes the element "a.nav-tab-action" when is clicked and grabs the data element value, which
//can be day, week, month or year and assigns that value to the variable chart. See show.html.erb
$("a.nav-tab-action").click(function(e) {
  $('svg').remove();
  $(".morris-hover.morris-default-style").remove();

  //First, prevent default of the event
  e.preventDefault();
  //Then, delete the current graph
  $('#testchart').unbind( "click" );
  data = []
  graph.setData(data);
  //After, adds the spinnig for loading
  $("#testchart").addClass("loading");
  //sets the labels of the graph
  $.getJSON("/reports/circuit_type/" + parseInt($("#testchart").data("circuit")), function(data) {
    graph_options.labels.push(data);
  });

  chart = $(this).data("chart");
  //Depending of the chart value, a url variable is assigned
  if (chart == "day") {
    url = "/reports/today_measures/";
    graph = testchart;
  } else if (chart == "week") {
    url = "/reports/week_measures/";
    graph = testchart;
  } else if (chart == "month") {
    url = "/reports/month_measures/";
    graph = testchart;
  } else if (chart == "year") {
    url = "/reports/year_measures/";
    graph = testchart;
  }
  //With the url set, the data to be displeyed is searched, plus the circuit id wich cames form data("circuit")
  $.getJSON(url + parseInt($("#testchart").data("circuit")), function(data) {
    //Removes the spinning class
    $("#testchart").removeClass("loading");
    if (chart == "month" || chart == "year") {
      graph = Morris.Bar(graph_options);
      graph.setData(data);
    } else {
    graph = Morris.Area(graph_options);
    graph.setData(data);
    }

  });

  //This takes care of .active class for the navs
  $(this).parent().parent().find(".active").removeClass("active");
  $(this).parent().addClass("active");
});//end click

//This is triggered when a change is made on the datepicker calendar
$("#datepicker").change(function(e) {
  //Get the date
  date = $( "#datepicker" ).datepicker( "getDate" );
  //Set data to empty array
  data = []
  //Clear the curent data with empty array
  graph.setData(data);
  //Add css class with the spinning wheel
  $("#testchart").addClass("loading");
  //Make de AJAX call to the server
  $.getJSON("/reports/specific_date_measures/" + parseInt($("#testchart").data("circuit")) + "/" + date, function(data) {
  //Set the new data
    graph.setData(data);
  //Remove the spinnig wheel  
    $("#testchart").removeClass("loading");
  });
  //AJAX call for labels
  $.getJSON("/reports/circuit_type/" + parseInt($("#testchart").data("circuit")), function(data) {
    graph_options.labels.push(data);
  $("a.nav-tab-action").parent().parent().find(".active").removeClass("active");
  });
});

