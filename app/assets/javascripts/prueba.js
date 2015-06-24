 $.getJSON("/reports/circuit_type/" + parseInt($("#testchart").data("circuit")), function(data){
      console.log(data);
      graph.labels.push(data);
  });
  console.log(graph.labels);