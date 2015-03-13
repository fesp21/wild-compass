# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

class ScanController
  init: ->
    console.log 'scan#init'
    return

  scan: ->
    console.log 'scan#scan'
    $(document).ready ->
      # Detect bag id
      
      $('#scan-form').submit (event) ->
        event.preventDefault()
        scan()
        return

      return
    return

this.WildCompass.scan = new ScanController

# Scan bag's datamatrix
scan = ->
  $.post(
    $('#scanned_hash').data('href') + '.json', scanned_hash: $('#scanned_hash').val()
  ).done (data) ->
    $('#scannable').html = data