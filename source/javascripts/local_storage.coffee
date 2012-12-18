window.Persist ||= {}

Persist.localStorage =
  initialize: ->
    ;
  file: (path, data) ->
    if data
      localStorage.setItem(path, data)
    else
      localStorage.getItem(path)
  toString: ->
    output = '\n'

    for n in [0...localStorage.length]
      key = localStorage.key(n)
      value = localStorage.getItem(key)

      output += "#{key}: #{value}\n"

    output
