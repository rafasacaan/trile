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
  "July", "August", "September", "October", "November", "December"],
 colors = ["#00E676","#1E88E5","#FFB74D","#FF7043","#B2FF59","#40C4FF"];

var checks = $( ":checkbox" );

$("#datepicker").datepicker({dateFormat: 'dd/mm/yy',inline: true});

var day_options = {
    element: 'testchart',
    hideHover: 'auto',
    data: [],
    xkey: 'created_at',
    ykeys: [],
    labels: [],
    resize: false,
    lineColors: colors,
    lineWidth: 2,
    fillOpacity: 0.03,
    pointSize: 3,
    resize: true,
    dateFormat: function(date) {
          d = new Date(date);
          var hours = d.getHours();
          var minutes = "0" + d.getMinutes();
          var seconds = "0" + d.getSeconds();
          return d.getDate()+'/'+(d.getMonth()+1)+'/'+d.getFullYear()+' '+hours+':'+minutes.substr(-2);
    }
};

var week_options = {
    element: 'testchart',
    hideHover: 'auto',
    data: [],
    xkey: 'created_at',
    ykeys: [],
    labels: [],
    resize: false,
    lineColors: colors,
    lineWidth: 2,
    fillOpacity: 0.03,
    pointSize: 3,
    resize: true,
    dateFormat: function(date) {
          d = new Date(date);
          var hours = d.getHours();
          var minutes = "0" + d.getMinutes();
          var seconds = "0" + d.getSeconds();
          return d.getDate()+'/'+(d.getMonth()+1)+'/'+d.getFullYear()+' '+hours+':'+minutes.substr(-2);
    }
};

var month_options = {
    element: 'testchart',
    data: [],
    xkey: 'dt',
    ykeys: [],
    labels: [],
    barColors: colors,
    xLabelFormat: function(d){
      date = new Date(d.label*1000);
      return date.getDate()+'/'+(date.getMonth()+1); 
    },
    dateFormat: function (x) { return new Date(x.label*1000); },
    xLabelAngle: 60
  };

var year_options = {
    element: 'testchart',
    data: [],
    xkey: 'dt',
    ykeys: [],
    labels: [],
    barColors: colors,
    xLabelAngle: 60
  };


var current_chart = null;

$(function() { 
 
  var result = set_url(); 
 
  setChart(result.url,null,result.radio_button);
 
 });

function set_url(){

  radio_button = $("input:radio[name=options]:checked").val();
  // Make sure to ask why result only works if is defined at the bottom
  url = "";
  if (radio_button == "day") {
    url = "/reports/data_tool_day";
  } else if (radio_button == "week") {
    url = "/reports/data_tool_week";
  } else if (radio_button == "month") {
    url = "/reports/data_tool_month";
  } else if (radio_button == "year") {
    url = "/reports/data_tool_year";
  }

  result = { url, radio_button};

  return result;
};

function setChart(url,date, radio_button){
  var date = date || new Date();
  date.setHours(0,0,0,0);

  $.getJSON(url + "/" + date, function(data) {
   $("#testchart").removeClass("loading");
  
    setLabels(radio_button);
  
   if (radio_button == "day"){
    current_chart = Morris.Line(day_options);
  } else if(radio_button == "week"){
    current_chart = Morris.Line(week_options);
  } else if(radio_button == "month"){
    current_chart = Morris.Bar(month_options);
  } else if (radio_button == "year"){
    current_chart = Morris.Bar(year_options);
  } 

    console.log(current_chart);   
    current_chart.setData(data);
  
  });

};

function setLabels(radio_button){
  
  if (radio_button == "day"){
    graph = day_options;
  } else if(radio_button == "week"){
    graph = week_options;
  } else if(radio_button == "month"){
    graph = month_options;
  } else if (radio_button == "year"){
    graph = year_options;
  }

  $.getJSON("/reports/labels", function(data) {
    for(i=0; i < data.length; i++){
      graph.ykeys.push(data[i]);
      graph.labels.push(data[i]);          
    }
  });
};

function arrayFilter(data,checkeds){
  response = data;
  var l = checkeds.length,
      arrayAux = [];
     
     while(l--){ 
        for(var i = 0; i < response.length; i++ ){
         if(response[i].hasOwnProperty(checkeds[l])){
            arrayAux.push(response[i]); 
          }
        }
     };
   response = arrayAux;
  return response;     
}; 

function graph_checkeds(checkeds, data, radio_button){

  //if there is checkeds, then filter the data, if checked is empty don't filter the data

  if (radio_button == "day"){
    current_chart = Morris.Line(day_options);
  } else if(radio_button == "week"){
    current_chart = Morris.Line(week_options);
  } else if(radio_button == "month"){
    current_chart = Morris.Bar(month_options);
  } else if (radio_button == "year"){
    current_chart = Morris.Bar(year_options);
  }

  if (checkeds.length) {
         current_chart.setData(arrayFilter(data,checkeds));
        }
  else {
         current_chart.setData(data);
        }
};

$("#datepicker").change(function(e) {
  $("#testchart").addClass("loading");
  //Get the date
  var date = $( "#datepicker" ).datepicker( "getDate" ),
      month = date.getMonth(); 
  $("#current_month").html(" Current month: " + monthNames[month]);
  //set chart
  setChart(date);
});

$("#circuit-table").change(function(e){
  var checkeds_raw =  _.filter(checks, function(check){ return check.checked; }), //all checks
      checkeds = _.map(checkeds_raw,function(checks){ return checks.id}); //only chekeds
  var date = $( "#datepicker" ).datepicker( "getDate" ) || new Date();//set the date 
  var url = set_url(); //sets the url depending on radio buttons, defaul "/reports/data_tool_day"

  date.setHours(0,0,0,0);

  $("#testchart").addClass("loading");
  
  $.getJSON(url.url + "/" + date, function(data){
      graph_checkeds(checkeds,data,url.radio_button);
      $("#testchart").removeClass("loading");    
    });
});