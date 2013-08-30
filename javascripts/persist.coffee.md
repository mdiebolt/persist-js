Persist JS
==========

Define root level namespace

    window.Persist ||= {}

Determines whether browser supports localStorage API.

    supportsLocalStorage = ->
      window.localStorage?

Version of `JSON.parse` that returns `undefined` instead of blowing up on invalid JSON.

    safeParse = (string) ->
      try
        return JSON.parse string
      catch e
        return undefined

Get an item from `localStorage`. Return `undefined` instead of blowing up if the item doesn't exist.

    safeGet = (string) ->
      try
        return localStorage.getItem(string)
      catch e
        return undefined

Transform a list of directories into a directory path string.

    constructDirectoryPath = (directories) ->
      path = directories.join('/')

      path += '/' unless path.length

      return path

Pull off leading `/` or trailing `/` in file path string

    normalizePath = (path) ->
      path = path.slice(1) if path[0] is '/'

      length = path.length

      path = path.substr(0, length - 1) if path[length - 1] is '/'

      return path

We assume the string represents a file if it has an extension

    isFile = (string) ->
      string.indexOf('.') > -1

Implement localStorage adapter. In the future we could support multiple adapters for Persistence mechanisms such as the HTML FileSystem API, Dropbox, GitHub gists, etc.

    storageMode = null

    Persist.localStorage =

When called with just a `path` string, looks up a file. When called with `data` also, writes a file, overwriting existing files at that location.

      file: (path, data) ->
        path = normalizePath(path)

        return unless path.length

        [directories..., fileName] = path.split '/'

Treat the file as a directory if there is no extension.

        unless isFile(fileName)
          directories.push(fileName)
          fileName = ''

File data is provided.

        if data?
          directoryPath = constructDirectoryPath(directories)

Check if there are already files saved in this directory. Otherwise, create a new directory.

          files = safeParse(safeGet(directoryPath)) || {}

          if isFile(fileName)
            files[fileName] = data

          localStorage.setItem(directoryPath, JSON.stringify(files))

No data was provided so we're using this as a getter.

        else
          if isFile(fileName)
            directoryPath = constructDirectoryPath(directories)

            if item = safeGet(directoryPath)
              JSON.parse(item)[fileName]
          else
            if item = safeGet(path)
              JSON.parse(item)

Remove a file or directory corresponding to a file path string.

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

Visualize the simulated file tree visually. Useful for debugging.

      toString: ->
        output = '\n'

        for n in [0...localStorage.length]
          key = localStorage.key(n)
          value = localStorage.getItem(key)

          output += "#{key}: #{value}\n"

        output

## Public API

Blow up if the browser doesn't support the localStorage API.

    if supportsLocalStorage()
      storageMode = 'localStorage'
    else
      throw new Error("Your browser doesn't support the local storage API")

Expose three simple methods for manipulating files: save, find, and delete.

    Persist.save = (filePath, data) ->
      Persist[storageMode].file(filePath, data)

    Persist.find = (filePath) ->
      Persist[storageMode].file(filePath)

    Persist.delete = (filePath) ->
      Persist[storageMode].remove(filePath)

Add public methods directly to the browser localStorage object. Not for the faint of heart.

    Persist.pollute = ->
      for method in ["save", "find", "delete"]
        localStorage.__proto__[method] = Persist[method]

      localStorage
