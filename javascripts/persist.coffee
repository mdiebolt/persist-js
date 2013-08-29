window.Persist ||= {}

do ->
  # support adapters for file system
  # and other storage methods
  storageMode = null

  supportsLocalStorage = ->
    window.localStorage?

  if supportsLocalStorage()
    storageMode = 'localStorage'

  Persist[storageMode].initialize()

  Persist.save = (filePath, data) ->
    Persist[storageMode].file(filePath, data)

  Persist.find = (filePath) ->
    Persist[storageMode].file(filePath)

  Persist.toString = ->
    Persist[storageMode].toString()
