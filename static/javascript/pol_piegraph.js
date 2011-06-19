function make_pol_pie(data) {
  var data_total = pv.sum(pv.map(data, function(x) { return x[1] }));
  data.sort(function(a,b) { return b[1] - a[1] });
  
  var w = 120,
      h = 120,
      r = w / 2,
      a = pv.Scale.linear(0, data_total).range(0, 2 * Math.PI);
  
  var color_func = function(d) {
    if (d[0] == "Republicans")
      return "#e60002"
    else if (d[0] == "Democrats")
      return "#186582"
    else return "#dcddde"
  };
  
  var vis = new pv.Panel()
      .width(240)
      .height(120);

  vis.add(pv.Wedge)
      .data(data)
      .top(r)
      .left(r)
      .outerRadius(r)
      .fillStyle(color_func)
      .angle(function(d) { return a(d[1]) })
      .title(function(d) { return d })
  
  vis.add(pv.Dot)
      .data(data)
      .left(140)
      .top(function() { return this.index * 12 + 50 })
      .fillStyle(color_func)
      .strokeStyle(null)
    .anchor("right").add(pv.Label)
      .text(function(d) { return d[0] });

  vis.render();
}
