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

  length = path.length

  path = path.substr(0, length - 1) if path[length - 1] is '/'

  return path

isFile = (string) ->
  string.indexOf('.') > -1

Persist.localStorage =
  file: (path, data) ->
    path = normalizePath(path)

    return unless path.length

    [directories..., fileName] = path.split '/'

    # treat the file as a directory if there is no extension
    unless isFile(fileName)
      directories.push(fileName)
      fileName = ''

    # file data is provided
    if data?
      directoryPath = constructDirectoryPath(directories)

      # see if there are already files saved in this
      # directory. Otherwise, create a new directory
      files = safeParse(safeGet(directoryPath)) || {}

      if isFile(fileName)
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
