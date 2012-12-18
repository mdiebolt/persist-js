window.Persist ||= {}

Persist.localStorage =
  initialize: ->
    ;

  file: (path, data) ->
    # strip off leading /
    path = path.slice(1) if path[0] is '/'

    [directories..., file] = path.split('/')

    if data && file
      directoryPath = directories.join('/')
      directoryPath += '/' unless directoryPath.length

      if (directoryContents = localStorage.getItem(directoryPath))
        try
          files = JSON.parse directoryContents

      files ||= {}

      files[file] = data

      localStorage.setItem(directoryPath, JSON.stringify(files))

      files
    else
      if file.indexOf('.') > -1
        directoryPath = directories.join('/')
        directoryPath += '/' unless directoryPath.length

        JSON.parse(localStorage.getItem(directoryPath))[file]
      else
        JSON.parse(localStorage.getItem(path))

  toString: ->
    output = '\n'

    for n in [0...localStorage.length]
      key = localStorage.key(n)
      value = localStorage.getItem(key)

      output += "#{key}: #{value}\n"

    output
