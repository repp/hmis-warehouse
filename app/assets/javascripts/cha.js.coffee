$(document).on 'change', '.cha-form.autosave', (e) ->
  form = $(e.target).closest('form')
  $savingIndicator = $('.j-saving-indicator')
  $savingIndicator.text('Saving').removeClass('hidden').addClass('saving c-spinner')
  $.ajax
    url: form.data('url'),
    type: 'PATCH',
    data: form.serialize()
  .done (e) ->
    console.log 'done'
    $savingIndicator.removeClass('saving c-spinner').addClass('saved').text('Saved!')
  .fail (e) ->
    console.log 'fail'
    $savingIndicator.removeClass('saving c-spinner').addClass('error').text('Error saving')
  .always ->
    setTimeout ->
      $savingIndicator.removeClass('saving').addClass('hidden')
    , 20000

$(document).on 'click', '.add-diagnosis', (e) ->
  $('.diagnosis-row.hidden').first().removeClass('hidden')

$(document).on 'click', '.remove-diagnosis', (e) ->
  row = $(e.target).closest('.diagnosis-row').first()
  inputs = row.find(':input')
  inputs.val('')
  inputs.first().change()
  row.addClass('hidden')

$(document).on 'click', '.add-medication', (e) ->
  $('.medication-rows.hidden').first().removeClass('hidden')

$(document).on 'click', '.remove-medication', (e) ->
  row = $(e.target).closest('.medication-rows').first()
  inputs = row.find(':input')
  inputs.val('')
  inputs.first().change()
  row.addClass('hidden')


# Scroll to element with id that matches hash
# https://css-tricks.com/snippets/jquery/smooth-scrolling/
scrollToElement = (event, offset=0, duration=1000) ->
  hash = $(event.currentTarget).attr('href')
  $target = $(hash)
  if $target.length
    event.preventDefault()
    $('html, body').animate { scrollTop: $target.offset().top - offset }, duration

$('a[href*="#"]')
  .not('[href="#"]')
  .not('[href="#0"]').on 'click', (event) ->
    scrollToElement event, 20
    event.currentTarget.blur()
