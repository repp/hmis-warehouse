#= require ./namespace

class App.PublicDashboards.NewClients.NewClients
  constructor: (@target, @data) ->
    dates = Object.keys(@data)
    previous_date_range = dates[0]
    current_date_range = dates[1]
    previous_count = @data[previous_date_range]
    current_count = @data[current_date_range]
    change = current_count / previous_count * 100 - 100 #As a percent

    $(@target + ' .previous-count .date-range').text previous_date_range
    $(@target + ' .previous-count .count').text previous_count
    $(@target + ' .current-count .date-range').text current_date_range
    $(@target + ' .current-count .count').text current_count
    if change > 0
      $(@target + ' .change').text '+' + change.toFixed(2) + '%'
    else
      $(@target + ' .change').text change.toFixed(2) + '%'
