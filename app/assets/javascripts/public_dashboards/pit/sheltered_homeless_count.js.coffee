#= require ./namespace

class App.PublicDashboards.Pit.ShelteredHomelessCount
    constructor: (@chart, @url) ->
      @fetch_data()
