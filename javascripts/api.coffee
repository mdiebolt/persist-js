window.Persist ||= {}

do ->
  # support adapters for file system
  # and other storage methods
  storageMode = null

  supportsLocalStorage = ->
    window.localStorage?

  if supportsLocalStorage()
    storageMode = 'localStorage'
  else
    throw new Error("Your browser doesn't support the local storage API")

  Persist.save = (filePath, data) ->
    Persist[storageMode].file(filePath, data)

  Persist.find = (filePath) ->
    Persist[storageMode].file(filePath)

  Persist.delete = (filePath) ->
    Persist[storageMode].remove(filePath)

  Persist.toString = ->
    Persist[storageMode].toString()
