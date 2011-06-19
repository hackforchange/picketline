function make_pie(data) {
  var data_total = pv.sum(pv.map(data, function(x) { return x[1] }));
  data.sort(function(a,b) { return b[1] - a[1] });
  
  var c = 100,
      r = c / 2,
      a = pv.Scale.linear(0, data_total).range(0, 2 * Math.PI);
  
  var vis = new pv.Panel()
      .width(c)
      .height(c);

  vis.add(pv.Wedge)
      .data(data)
      .top(r)
      .left(r)
      .outerRadius(r)
      .fillStyle(function(d) { return pv.Colors.category20().range()[this.index] })
      .angle(function(d) { return a(d[1]) })
      .title(function(d) { return d })
  
  vis.render();
}

function pie_dot(data_point) {
  var vis = new pv.Panel()
      .width(14)
      .height(14);
  
  vis.add(pv.Dot)
      .data([data_point])
      .left(7)
      .top(7)
      .fillStyle(function(d) { return pv.Colors.category20().range()[this.index] })
      .strokeStyle(null)

  vis.render();
}

