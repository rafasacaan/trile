//= require jquery-1.8.3.min
//= require bootstrap.min
//= require jquery.dcjqaccordion.2.7
//= require jquery.scrollTo.min
//= require jquery.nicescroll
//= require jquery.sparkline
//= require common-scripts
//= require gritter/js/jquery.gritter
//= require gritter-conf
//= require sparkline-chart
//= require zabuto_calendar


$(function () {
        var unique_id = $.gritter.add({
            // (string | mandatory) the heading of the notification
            title: 'Bienvenido a Tu Trile',
            // (string | mandatory) the text inside the notification
            text: 'En Mi Trile podrás encontrar toda la información para gestionar tu consumo eléctrico y ser más eficiente.',
            // (string | optional) the image to display on the left
            image: '',
            // (bool | optional) if you want it to fade out on its own or just sit there
            sticky: false,
            // (int | optional) the time you want it to be alive for before fading out
            time: '3000',
            // (string | optional) the class name you want to apply to that specific message
            class_name: 'my-sticky-class'
        });
      
  return false;

});        
  
  
$(function () {
    var options = {
        type: 'line',
        resize: true,
        height: '75',
        width: '90%',        
        lineWidth: 1,
        lineColor: '#fff',
        spotColor: '#64FFDA',
        fillColor: '',
        highlightLineColor: '#ffffff',
        spotRadius: 4,
        valueSpots: {':49': '#64FFDA', '50:': 'red'}};
        
            
    $.getJSON("/reports/welcome_index", function(data) {
      for (i = 0; i < data.length; i++){
        $.getJSON("/reports/last_five/" + data[i].id, function(data){
            $("#linechart-"+data[0]).sparkline(data[1], options);
            $("#p-"+data[0]).html('<br/>Promedio Últimos 20 minutos<br><b class="average">' + average(data[1]) +'</b>');
            });
        };    
    });
});

function average(array) {
    var sum = 0;
    for( var i = 0; i < array.length; i++ ){
        sum += parseInt( array[i], 10 ); //don't forget to add the base
    };
     var avg = sum/array.length;        // The function returns the product of p1 and p2
     return avg;
};