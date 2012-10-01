$(document).onReady ->
  init()

init = ->
  #Show tasks table
  tasks_update()
  delegates_update()

  #Set event handlers and defaults for "Add task" field
  $('tasks_add_task').setValue ''
  resize_input = ->
    height = $('tasks_add_task').value().split(/\n/).length * 19 + 18
    $('tasks_add_task').setHeight(height if height > 51)
  $('tasks_add_task').on 'enter', resize_input
  $('tasks_add_task').on 'backspace', resize_input
  $('tasks_add_task').on 'shift+enter', tasks_add

  $('delegates_add').on 'enter', (e) -> delegates_add(e)

tasks_add = ->
  Xhr.load '/tasks/add',
    method: 'POST'
    params:
      task: $('tasks_add_task').value().replace(/\n/g,"<br>")
    onSuccess: ->
      $('tasks').fire 'tasks_changed'
      $('tasks_add_task').setValue ''

tasks_update = ->
  Xhr.load '/tasks/show',
    onSuccess: ->
      $('tasks').update @.text
      $('tasks_add_task').setWidth $$('div#tasks > table')[0].get('clientWidth')
      $('tasks').stopObserving('tasks_changed').on 'tasks_changed', tasks_update
      $('tasks').find('a.del').forEach (el) ->
        el.stopObserving('click').on('click', (e) -> tasks_del(e))
      $('tasks').find('td.task_body').forEach (el) ->
        el.stopObserving('dblClick').on('dblclick', (e) -> tasks_edit(e))

tasks_del = (e) ->
  e.preventDefault()
  Xhr.load "/tasks/del/#{e.target.get 'rel'}",
    method: 'POST'
    onSuccess: -> $('tasks').fire 'tasks_changed'

tasks_edit = (e) ->
  $('tasks_inline_edit').parent().update("<span>#{$('tasks_inline_edit').value()}</span>") if $('tasks_inline_edit')
  Xhr.load "/tasks/inline_edit/#{e.target.get 'rel'}",
    method: 'POST'
    onSuccess: ->
      e.target.parent().update @.text
      $('tasks_inline_edit').stopObserving('shift+enter').on('shift+enter', (e) -> tasks_edit_save(e))
      $('tasks_inline_edit').stopObserving('esc').on 'esc', (e) -> tasks_cancel_edit(e)
      $('tasks_inline_edit').setValue e.target.get('innerHTML').replace(/<br>/g, "\n").trim()
      $('tasks_inline_edit').setWidth $('tasks_inline_edit').parent().get('clientWidth')
      $('tasks_inline_edit').focus()

tasks_cancel_edit = (e) ->
  e[0].preventDefault() if e
  tasks_update()

tasks_edit_save = (e) ->
  if $('tasks_inline_edit').value() == ""
    $('debug').update('Empty values not allowed!')
    return 0

  console.log $('tasks_inline_edit').value().replace(/\n/, "<br>")
  Xhr.load "/tasks/save/#{e[0].target.get 'rel'}",
    method: 'POST'
    params:
      body: $('tasks_inline_edit').value().replace(/\n/g,"<br>")
    onSuccess: -> $('tasks').fire 'tasks_changed'

delegates_add = (e) ->
  e[0].preventDefault()
  Xhr.load '/delegates/add',
    method: 'POST'
    params:
      value: $('delegates_add').value().trim()
    onSuccess: ->
      $('delegates').fire 'changed'
      $('delegates_add').value ''

delegates_update = ->
  Xhr.load '/delegates/show',
    onSuccess: ->
      $('delegates').update @.text
      $('delegates').stopObserving('changed').on 'changed', delegates_update
      $('delegates').find('a.del').forEach (el) ->
        el.stopObserving('click').on('click', (e) -> delegates_del(e))

delegates_del = (e) ->
  e.preventDefault()
  Xhr.load "/delegates/del/#{e.target.get 'rel'}",
    method: 'POST'
    onSuccess: -> $('delegates').fire 'changed'