
var margin = {top: 50, right: 0, bottom: 10, left: 400},
    width = 1500- margin.left - margin.right,
    height = 500 - margin.top - margin.bottom;

// create tooltip element  
var tooltip = d3.select("body")
  .append("div")
  .attr("class","d3-tooltip")
  .style("position", "absolute")
  .style("z-index", "10")
  .style("visibility", "hidden")
  .style("padding", "15px")
  .style("background", "rgba(0,0,0,0.6)")
  .style("border-radius", "5px")
  .style("color", "#fff")
  .text("a simple tooltip")
  .html("<div id='tipDiv'></div>");

var graph_elems = {}

const dir = "data/"
make_diverging_stacked(dir+"likert-data.csv", "likert")
make_diverging_stacked(dir+"rank-data.csv", "rank")
make_bar(dir+"technologies-data.csv", "tech")
make_bar(dir+"file-types-data.csv", "file_types")
make_bar(dir+"data-model-data.csv", "data_model")

function make_diverging_stacked(csv, div_id){

  var y = d3.scaleBand()
    .rangeRound([0, height])
    .padding(0.3);

  var x = d3.scaleLinear()
      .rangeRound([0, width]);

  var color = d3.scaleOrdinal()
      .range(["#d7191c", "#fdae61", "#ffff00", "#a6d96a", "#1a9641"]);

  var xAxis = d3.axisTop()
      .scale(x)

  var yAxis = d3.axisLeft()
      .scale(y)

  d3.csv(csv, function(error, data) {
    
      var question_indexes = {}
      data.forEach(function(d, i) {
        question_indexes[d.Question] = i
      })

    graph_elems[div_id] = d3.select("#" + div_id).append("svg")
      .attr("width", width + margin.left + margin.right)
      .attr("height", height + margin.top + margin.bottom)
      .attr("id", "d3-plot")
      .append("g")
      .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

    const ratings = div_id == "likert" ? [
      "significant negative impact",
      "negative impact",
      "little or no impact",
      "positive impact",
      "major positive impact"
    ] : ["Ranked 1st", "Ranked 2nd", "Ranked 3rd", "Ranked 4th", "Ranked 5th"]

    color.domain(ratings);

    var averages = {}
    data.forEach(function(d) {
      averages[d.Question] =  ((parseInt(d["1"]) + parseInt(d["2"]*2)  + parseInt(d["3"]*3)  + parseInt(d["4"]*4)   + parseInt(d["5"]*5) )/parseInt(d.N)).toFixed(2)  
    })

    // NOTICE: Diverging stacked bar chart is modified from https://github.com/wpoely86/D3.js-Diverging-Stacked-Bar-Chart
    // wpoely86/D3.js-Diverging-Stacked-Bar-Chart is licensed under the Apache License 2.0
    // Modifications include: style changes, different data, all mouse and click events, tooltip, addition of pie chart and transition to regular bar chart

    data.forEach(function(d) {
      averages[d.Question] =  ((parseInt(d["1"]) + parseInt(d["2"]*2)  + parseInt(d["3"]*3)  + parseInt(d["4"]*4)   + parseInt(d["5"]*5) )/parseInt(d.N)).toFixed(2)
      // calc percentages
      d[ratings[0]] = +d[1]*100/d.N;
      d[ratings[1]] = +d[2]*100/d.N;
      d[ratings[2]] = +d[3]*100/d.N;
      d[ratings[3]] = +d[4]*100/d.N;
      d[ratings[4]] = +d[5]*100/d.N;
      var x0 = -1*(d[ratings[2]]/2+d[ratings[1]]+d[ratings[0]]);
      var idx = 0;
      d.boxes = color.domain().map(function(name) { 
        return {q: d["Question"], name: name, x0: x0, x1: x0 += +d[name], N: +d.N, n: +d[idx += 1], bar_clicked: false, tooltip: "visible"}; });
    });

    var min_val = d3.min(data, function(d) {
      return d.boxes["0"].x0;
    });

    var max_val = d3.max(data, function(d) {
      return 80;
    });

    x.domain([min_val, max_val]).nice();
    y.domain(data.map(function(d) { return d.Question; }));

    graph_elems[div_id].append("g")
        .attr("class", "x axis")
        .call(xAxis);

    var y_axis = graph_elems[div_id].append("g")
        .attr("class", "y axis");
        
    y.domain(data.map(function(d) { return d.Question; }));  
    y_axis.call(yAxis);
    

    var y_clicked = false
    graph_elems[div_id].selectAll(".y.axis .tick").on("click", function(d, i){
        var question = d
        if(!y_clicked){
          graph_elems[div_id].selectAll(".y.axis .tick").each(function(d,i){
            if(d!=question){d3.select(this).style("opacity", 0);}
            else{d3.select(this).style("opacity", 1);}
          })
          graph_elems[div_id].selectAll("#bar").each(function(d,i){
            d3.select(this).attr("x", function(d) { return x(d.x0); })
            if(d.q !=question){
              d.tooltip = "hidden";
              d3.select(this).style("opacity", 0);
            }
            else{
              d.tooltip = "visible";
              d3.select(this).style("opacity", 1);
            }
          
          })
          graph_elems[div_id].selectAll("#bar_text").each(function(d,i){
            if(d.q !=question){d3.select(this).style("opacity", 0);}
            else{d3.select(this).style("opacity", 1);}
          })
          
          y_clicked = true
        }else{
          graph_elems[div_id].selectAll(".y.axis .tick").style("opacity", 1);
          graph_elems[div_id].selectAll("#bar")
            .style("opacity", 1)
            .attr("x", function(d, i) { 
              d.tooltip = "visible";
              return x(d.x0); 
            });
          graph_elems[div_id].selectAll("#bar_text").style("opacity", 1);
          y_clicked = false;
        }

      });

      graph_elems[div_id].selectAll(".y.axis .tick").on("mouseover", function(d, i) {        
        if (!y_clicked){d3.select(this).style("opacity", 0.2);}
          tooltip.style("visibility", "visible")
          .style("left", d3.select(this).attr("x") + "px")     
          .style("top", d3.select(this).attr("y") + "px")
          .style("top", (event.pageY-10)+"px")
          .style("left",(event.pageX+10)+"px")
          .style("width", 150)
          .html("<div id='pie_"+div_id+"'></div>")
          make_pie(i, div_id)
      })
      .on("mouseout", function() {
        if (!y_clicked){d3.select(this).style("opacity", 1);}
        tooltip.style("visibility", "hidden")
      })


      

    var vakken = graph_elems[div_id].selectAll(".question")
      .data(data)
      .enter().append("g")
      .attr("class", "bar")
      .attr("transform", function(d) { return "translate(0," + y(d.Question) + ")"; });

    var bars = vakken.selectAll("rect")
      .data(function(d) { return d.boxes; })
      .enter().append("g").attr("class", "subbar");


    bars.on("mouseover", function(d, i) {
      if(d.tooltip != "hidden"){
        tooltip
          .html(`</p>${d.q}: <br><p class="stats">Average ${averages[d.q]}</p><br> ${d.name}:</p> <p class="stats">n = ${d.n} <br><br> ${((d.n/d.N)*100).toFixed(2)}% of respondents</p>`)
          .style("left", d3.select(this).attr("x") + "px")     
          .style("top", d3.select(this).attr("y") + "px")
          .style("visibility", d.tooltip);        
        d3.select(this)
          .style("opacity", 0.2)
          .on("mousemove", function(){
            tooltip
              .style("top", (event.pageY-10)+"px")
              .style("left",(event.pageX+10)+"px");
          })
          .on("mouseout", function() {
            tooltip.html(``).style("visibility", "hidden");
            d3.select(this).style("opacity", 1);
          })
      }
    });
        

    bars.append("rect")
      .attr("id", "bar")
      .attr("height", y.bandwidth())
      .attr("x", function(d) { return x(d.x0); })
      .attr("width", function(d) { return x(d.x1) - x(d.x0); })
      .style("fill", function(d) { return color(d.name); })


    bars.on("click", function(d){
      d3.select("#pie" + question_indexes[d.q]).remove();
      graph_elems[div_id].selectAll(".y.axis .tick").style("opacity", 1);
      var rank = d.name;
      if(d.bar_clicked== false){
        graph_elems[div_id].selectAll("#bar_text").style("opacity", 0);
        graph_elems[div_id].selectAll("#bar").each(function(d,i){
          d.tooltip = "hidden";
          d.bar_clicked = true;
          if(d.name != rank){d3.select(this).style("opacity", 0);}
          else {d3.select(this)
              .style("opacity", 1)
              .attr("x", x(0));
          }
        });
      }else{
        graph_elems[div_id].selectAll("#bar_text").style("opacity", 1);
        graph_elems[div_id].selectAll("#bar").each(function(d,i){
          d.tooltip = "visible";
          d.bar_clicked = false;
          d3.select(this)
          .style("opacity", 1)
          .attr("x", x(d.x0));
        });
      }
    });

    bars.append("text")
      .attr("id", "bar_text")
      .attr("x", function(d) { return x(d.x0); })
      .attr("y", y.bandwidth()/2)
      .attr("dy", "0.5em")
      .attr("dx", "0.5em")
      .style("font" ,"10px sans-serif")
      .style("text-anchor", "begin")
      .text(function(d) { return d.n !== 0 && (d.x1-d.x0)>3 ? `${((d.n/d.N)*100).toFixed(2)}%` : "" });

    vakken.insert("rect",":first-child")
      .attr("height", y.bandwidth())
      .attr("x", "1")
      .attr("width", width)
      .attr("fill-opacity", "0.5")
      .style("fill", "#F5F5F5")
      .attr("class", function(d,index) { return index%2==0 ? "even" : "uneven"; });

    graph_elems[div_id].append("g")
      .attr("class", "y axis")
      .append("line")
      .attr("x1", x(0))
      .attr("x2", x(0))
      .attr("y2", height);


    var startp = graph_elems[div_id].append("g").attr("class", "legendbox").attr("id", "mylegendbox");
    var legend = startp.selectAll(".legend")
      .data(color.domain().slice())
      .enter().append("g")
      .attr("class", "legend")
      .attr("transform", function(d, i) {
        return "translate(" + (((d.length+220)*i)-150) + ",-45)"; 
      });

    legend.append("rect")
      .attr("x", 0)
      .attr("width", 18)
      .attr("height", 18)
      .style("fill", color);

    legend.append("text")
      .attr("x", 22)
      .attr("y", 9)
      .attr("dy", ".35em")
      .style("text-anchor", "begin")
      .style("font" ,"10px sans-serif")
      .text(function(d) { return d; });

    d3.selectAll(".axis path")
      .style("fill", "none")
      .style("stroke", "#000")
      .style("shape-rendering", "crispEdges")

    d3.selectAll(".axis line")
      .style("fill", "none")
      .style("stroke", "#000")
      .style("shape-rendering", "crispEdges")

    var movesize = width/2 - startp.node().getBBox().width/2;
    d3.selectAll(".legendbox").attr("transform", "translate(" + movesize  + ",0)");

    function make_pie(question_index, div_id){

      var pie_data = data[question_index].boxes;

      var pie_size = 100

      graph_elems[div_id + "_pie" + question_index] = d3.select("#pie_"+div_id).append("svg")
      .attr("width", pie_size*2)
      .attr("height", pie_size*2)
            
      var g = graph_elems[div_id + "_pie"+ question_index].append("g")
        .attr("transform", "translate(" + pie_size + "," + pie_size + ")")
        .attr("id", "pie" + question_index);

      var pie = d3.pie().value(function(d) { 
          return ((d.n/d.N)*100); 
        });

      radius = pie_size;
      var path = d3.arc()
        .outerRadius(radius - 10)
        .innerRadius(0);

      var label = d3.arc()
        .outerRadius(radius)
        .innerRadius(radius - 80);

      var arc = g.selectAll(".arc")
        .data(pie(pie_data))
        .enter().append("g")
        .attr("class", "arc");

      arc.append("path")
        .attr("d", path)
        .attr("fill", function(d) { return color(d.data.name); });
        
      arc.append("text")
        .attr("transform", function(d) { 
                return "translate(" + label.centroid(d) + ")"; 
        })
        .html(function(d) { return "n = " + d.data.n + " (" +((d.data.n/d.data.N)*100).toFixed(2) + "%)" });

      graph_elems[div_id].append("g")
        .attr("transform", "translate(" + (width / 2 - 120) + "," + 20 + ")")
        .append("text")
        .text(pie_data.name)
        .attr("class", "title")

    }


  });

}

function make_bar(csv, div_id){
  d3.csv(csv, function(error, data) {
    console.log(data)

    graph_elems[div_id] = d3.select("#" + div_id).append("svg")
          .attr("width", width + margin.left + margin.right)
          .attr("height", height + margin.top + margin.bottom + d3.max(data, function(d) { return d.category.length; })*5 )
          .append("g")
          .attr("transform", "translate(" + margin.left + "," + margin.top + ")");
          
    var x = d3.scaleBand()
      .range([0, width])
      .padding(0.1);
    var y = d3.scaleLinear()
      .range([height, 0]);

      // format the data
    data.forEach(function(d) {
      d.amount = +d.amount
    });

    // Scale the range of the data in the domains
    x.domain(data.map(function(d) { return d.category; }));
    y.domain([0, d3.max(data, function(d) { return +d.amount; })]);

        // append the rectangles for the bar chart
    var bars = graph_elems[div_id].selectAll(".bar")
        .data(data)
      .enter().append("rect")
        .attr("class", "bar")
        .attr("x", function(d) { return x(d.category); })
        .attr("width", x.bandwidth())
        .attr("y", function(d) { return y(d.amount); })
        .attr("height", function(d) { return height - y(d.amount); })
        .style("fill", "#0099ff");

    bars
      .on("mouseover", function(d) { 
        d3.select(this).style("opacity", 0.5)
        tooltip
          .style("left", d3.select(this).attr("x") + "px")     
          .style("top", d3.select(this).attr("y") + "px")
          .style("visibility", "visible")
          .html("<p>"+d.category+": <br><p class='stats'>n = "+ d.amount+" <br><br> " 
            +((d.amount/d.total)*100).toFixed(2)+ "% of respondents</p>"
            + d.note.replaceAll(";", "<br>- ") + "</p>");    
      })          
      .on("mousemove", function(){
        tooltip
          .style("top", (event.pageY-10)+"px")
          .style("left",(event.pageX+10)+"px");
      })
      .on("mouseout", function() { 
        tooltip.style("visibility", "hidden")
        d3.select(this).style("opacity", 1)
      });
      
    graph_elems[div_id].append("g")
      .attr("transform", "translate(0," + height + ")")
      .call(d3.axisBottom(x))
      .selectAll("text")	
        .style("text-anchor", "end")
        .attr("dx", "-.8em")
        .attr("dy", ".15em")
        .attr("transform", "rotate(-65)");

    graph_elems[div_id].append("g")
      .call(d3.axisLeft(y));

  });
}
