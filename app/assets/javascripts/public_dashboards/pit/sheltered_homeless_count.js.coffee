#= require ./namespace

class App.PublicDashboards.Pit.ShelteredHomelessCount
    constructor: (@chart, @url) ->
      @fetch_data()

    fetch_data: =>
      $.get @url, (return_data) =>
        sheltered_count = return_data['sheltered_count']
        category_count = Object.values(return_data['category_count'])
        category_count.splice(-2, 2) # Ignore safe haven and street outreach

        labels = category_count .map (data) -> data['project_type']
        chart_data = category_count .map (data) -> data['count']

        colors = [
          "#00a65a",
          "#f39c12",
          "#00c0ef",
        ]

        @data =
          labels: labels
          sheltered_count: sheltered_count
          datasets: [ {
            data: chart_data
            backgroundColor: colors
            hoverBackgroundColor: colors
          } ]

        @set_options()
        @show_chart()

    set_options: =>
      @options =
        segmentShowStroke: true
        segmentStrokeColor: '#fff'
        segmentStrokeWidth: 1
        cutoutPercentage: 70
        animation:
          animationSteps: 100
          animationEasing: 'easeOutBounce'
          animateRotate: true
          animateScale: true
          responsive: true
          maintainAspectRatio: true
        # legendTemplate: '<ul class="<%=name.toLowerCase()%>-legend"><% for (var i=0; i<segments.length; i++){%><li><span style="background-color:<%=segments[i].fillColor%>"></span><%if(segments[i].label){%><%=segments[i].label%><%}%></li><%}%></ul>'
        tooltipFontSize: 10
        tooltips:
          mode: 'index'
          position: 'nearest'
          displayColors: false
          callbacks:
            label: (tooltipItem, data) ->
              ph_categories = [3,10,13]
              value = data.datasets[tooltipItem.datasetIndex].data[tooltipItem.index];
              if data.labels[tooltipItem.index] == "Permanent Housing"
                text = [data.labels[tooltipItem.index] + ": " + value + (if value is 1 then " Client" else " Clients")]
                text.push("")
                for category in ph_categories
                  text.push (data.sheltered_count[category].project_type + ": " + data.sheltered_count[category].count + (if value is 1 then " Client" else " Clients"))
              else
                text = data.labels[tooltipItem.index] + ": " + value + (if value is 1 then " Client" else " Clients")
              return text

    show_chart: =>
      sheltered_homeless_count_chart = new Chart @chart,
        type: 'doughnut'
        data: @data
        options: @options
