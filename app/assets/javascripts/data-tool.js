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
    dateFormat: function(date) {
          d = new Date(date);
          var hours = d.getHours();
          var minutes = "0" + d.getMinutes();
          var seconds = "0" + d.getSeconds();
          return d.getDate()+'/'+(d.getMonth()+1)+'/'+d.getFullYear()+' '+hours+':'+minutes.substr(-2);
    }
};

var current_chart = Morris.Line(graph);

$(function() {
  $.getJSON("/reports/labels", function(data) {
    for(i=0; i < data.length; i++){
      graph.ykeys.push(data[i]);
      graph.labels.push(data[i]);          
    }
  });

  $.getJSON("/reports/index_measures", function(data) {
   $("#testchart").removeClass("loading");
    current_chart.setData(data);
  });

});

$("#circuit-table").change(function(e){
  var checkeds_raw =  _.filter(checks, function(check){ return check.checked; }),
      checkeds = _.map(checkeds_raw,function(checks){ return checks.id}),
      response;


  $.getJSON("/reports/index_measures", function(data){
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
            
    current_chart.setData(response);

  });
  


  

});

function findByKeys(array, keyes){
  var arr = [];
  for (var i = 0; i < array.length; i++){
    for (var j = 0; i < keyes.length; j++){
      if (Object.keys(array[i]) == keyes[j]){
        arr.push(array[i]);
      }
    }
  }
 return arr; 
};


$("#datepicker").change(function(e) {
  //Get the date
  var date = $( "#datepicker" ).datepicker( "getDate" );
  var month = date.getMonth(); 
  $("#current_month").html(" Current month: " + monthNames[month]);
});