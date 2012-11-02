$(document).onReady ->
  $(document).find('span.a.login')[0].on 'click', -> doLogin()
  navigator.id.watch
    loggedInUser: ->
      Xhr.load '/auth/get_mail',
        onSuccess: @.text
    onlogin: (assertion) ->
      Xhr.load '/auth/auth',
        method: 'POST'
        params:
          assertion: assertion
        onSuccess: -> window.location = '/'
        onFailure: -> alert 'Not authorized!'
    onlogout: ->


doLogin = ->
  Xhr.load '/auth/check',
    method: 'POST'
    params:
      user: $('login').value()
    onSuccess: -> navigator.id.request()
    onFailure: -> alert @.text