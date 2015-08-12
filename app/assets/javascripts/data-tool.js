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
  uri = set_url();  
  setChart(uri,null);
});

function set_url(){

  var radio_button = $("input:radio[name=options]:checked").val();
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

  result = url;

  return result;
};

function setChart(url, date){
  var date = date || new Date();
  date.setHours(0,0,0,0);  
  var radio_button = $("input:radio[name=options]:checked").val();
  setLabels(radio_button);

  $("#testchart").addClass("loading");

  $.getJSON(url  + "/" + date, function(data) {
   
   $("#testchart").removeClass("loading");
    
   if (radio_button == "day") {
    current_chart = Morris.Line(day_options);
    current_chart.setData(data);
  } else if (radio_button == "week") {
    current_chart = Morris.Line(week_options);
    current_chart.setData(data);
  } else if (radio_button == "month") {
    console.log('month');
    current_chart = Morris.Bar(month_options);
    current_chart.setData(data);
  } else if (radio_button == "year") {
    current_chart = Morris.Bar(year_options);
    current_chart.setData(data);
  }
  });
}

function setLabels(radio_button){

  if (radio_button == "day"){
    graphic = day_options;
  } else if(radio_button == "week"){
    graphic = week_options;
  } else if(radio_button == "month"){
    graphic = month_options;
  } else if (radio_button == "year"){
    graphic = year_options;
  }

      graphic.ykeys = [];
      graphic.labels = [];  

  $.getJSON("/reports/labels", function(data) {
    for(i=0; i < data.length; i++){
      graphic.ykeys.push(data[i]);
      graphic.labels.push(data[i]);          
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

$("#reload").click(function(e){
  //Remove from DOM the elements created by morris before, so they don't crush on each click event
  $('svg').remove();
  $(".morris-hover.morris-default-style").remove(); 
  uri = set_url(); 
  var date = $( "#datepicker" ).datepicker( "getDate" ); 
  setChart(uri,date);
})

$("#circuit-table").change(function(e){
  var checkeds_raw =  _.filter(checks, function(check){ return check.checked; }),
      checkeds = _.map(checkeds_raw,function(checks){ return checks.id}),
      response;
  var date = $( "#datepicker" ).datepicker( "getDate" ) || new Date();
  date.setHours(0,0,0,0);
  $("#testchart").addClass("loading");
  uri = set_url(); 
  $.getJSON(uri  + "/" + date, function(data){
      response = data;
      var l = checkeds.length,
          arrayAux = [];
      if (checkeds.length) {
      while(l--){ 
        for(var i = 0; i < response.length; i++ ){
         if(response[i].hasOwnProperty(checkeds[l])){
          
          arrayAux.push(response[i]); }
        
           }        
        };
        response = arrayAux;     
     };
    $("#testchart").removeClass("loading");        
    current_chart.setData(response);
  });

});


$("#datepicker").change(function(e) {
  //Get the date
  var date = $( "#datepicker" ).datepicker( "getDate" );
  var month = date.getMonth(); 
  $("#current_month").html(" Current month: " + monthNames[month]);
});