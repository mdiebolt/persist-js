window.Persist ||= {}

safeParse = (string) ->
  try
    return JSON.parse string
  catch e
    return undefined

safeGet = (string) ->
  try
    return localStorage.getItem(string)
  catch e
    return undefined

constructDirectoryPath = (directories) ->
  path = directories.join('/')

  path += '/' unless path.length

  return path

normalizePath = (path) ->
  path = path.slice(1) if path[0] is '/'

  return path

isFile = (string) ->
  string.indexOf('.') > -1

Persist.localStorage =
  initialize: ->
    ;

  file: (path, data) ->
    path = normalizePath(path)

    [directories..., fileName] = path.split '/'

    # weird hack if we only have a directory
    unless directories.length
      unless isFile(fileName)
        directories = [fileName]
        fileName = ''

    # file data is provided
    if data?
      directoryPath = constructDirectoryPath(directories)

      # see if there are already files saved in this
      # directory. Otherwise, create a new 'directory'
      files = safeParse(safeGet(directoryPath)) || {}

      if fileName.length
        files[fileName] = data

      localStorage.setItem(directoryPath, JSON.stringify(files))
    # no data was provided so we're using this as a getter
    else
      if isFile(fileName)
        directoryPath = constructDirectoryPath(directories)

        if item = safeGet(directoryPath)
          JSON.parse(item)[fileName]
      else
        if item = safeGet(path)
          JSON.parse(item)

  remove: (path) ->
    path = normalizePath(path)

    [directories..., fileName] = path.split '/'

    if isFile(fileName)
      directoryPath = constructDirectoryPath(directories)

      if item = safeGet(directoryPath)
        obj = JSON.parse(item)

        delete obj[fileName]

        localStorage.setItem(directoryPath, JSON.stringify(obj))
    else
      path = path.slice(0, -1) if path[path.length - 1] is '/'

      localStorage.removeItem(path)

  toString: ->
    output = '\n'

    for n in [0...localStorage.length]
      key = localStorage.key(n)
      value = localStorage.getItem(key)

      output += "#{key}: #{value}\n"

    output
