#= require ./namespace

class App.PublicDashboards.Ph.LengthOfStay
  constructor: (@chart, @url) ->
    @fetch_data()

  fetch_data: =>
    $.get @url, (return_data) =>
      if return_data.length == 0
        @chart.before('<p class="alert alert-warning">No data found</p>')

      else
        #Loop over all datasets in return_data
        labels = Object.keys(return_data[0]["data"])

        @data = {
          labels: labels,
          datasets: []
        }
        @organize_datasets(return_data)
        @set_options()
        @show_chart()

  set_options: =>
    @options =
      showScale: true
      scaleShowGridLines: true
      scaleGridLineColor: 'rgba(0,0,0,.05)'
      scaleGridLineWidth: 1
      scaleShowHorizontalLines: true
      scaleShowVerticalLines: true
      bezierCurve: true
      bezierCurveTension: 0.4
      pointDot: true
      pointDotRadius: 4
      pointDotStrokeWidth: 1
      pointHitDetectionRadius: 20
      scales: yAxes: [ { ticks: callback: (value) -> value + (if value is 1 then " Day" else " Days")} ]
      datasetStroke: true
      datasetStrokeWidth: 2
      datasetFill: true
      maintainAspectRatio: true
      responsive: true
      tooltipFontSize: 12
      tooltips:
        mode: 'index'
        position: 'nearest'
        callbacks:
          label: (tooltipItem, data) ->
            value = data.datasets[tooltipItem.datasetIndex].data[tooltipItem.index];
            text = data.datasets[tooltipItem.datasetIndex].label + ": " + value + (if value is 1 then " Day" else " Days")

  show_chart: =>
    length_of_stay_chart = new Chart @chart,
      type: 'line'
      data: @data
      options: @options

  organize_datasets: (return_data) =>
    for dataset in return_data
      label = dataset["title"]
      chart_data = Object.values(dataset["data"])

      @data["datasets"].push {
        label: label,
        fillColor: 'rgba(151,187,205,0.2)',
        strokeColor: 'rgba(151,187,205,1)',
        pointColor: 'rgba(151,187,205,1)',
        pointStrokeColor: '#fff',
        pointHighlightFill: '#fff',
        pointHighlightStroke: 'rgba(151,187,205,1)',
        data: chart_data,
      }
