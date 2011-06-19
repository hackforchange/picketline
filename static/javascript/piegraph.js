function make_pie() {
  var data = [["a", 10],["b", 2],["c.", 4],["etc.", 1],["b", 2],["c", 4],["d", 5],["b", 2],["c", 4],["d", 5]];
  var data_total = pv.sum(pv.map(data, function(x) { return x[1] }));
  data.sort(function(a,b) { return b[1] - a[1] });
  
  var w = 180,
      h = 180,
      r = w / 2,
      a = pv.Scale.linear(0, data_total).range(0, 2 * Math.PI);
  
  var vis = new pv.Panel()
      .width(260)
      .height(400);

  vis.add(pv.Wedge)
      .data(data)
      .top(r)
      .left(r + 40)
      .outerRadius(r)
      .fillStyle(function(d) { return pv.Colors.category20().range()[this.index] })
      .angle(function(d) { return a(d[1]) })
      .title(function(d) { return d })
  
  vis.add(pv.Dot)
      .data(data)
      .left(10)
      .top(function() { return this.index * 12 + 220 })
      .fillStyle(function(d) { return pv.Colors.category20().range()[this.index] })
      .strokeStyle(null)
    .anchor("right").add(pv.Label)
      .text(function(d) { return d[0] });

  vis.render();
}
