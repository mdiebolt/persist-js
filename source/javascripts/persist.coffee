#= require local_storage
#= require file_system

window.Persist ||= {}

do ->
  storageMode = null

  supportsLocalStorage = ->
    window.localStorage?

  supportsFileSystem = ->
    window.requestFileSystem? || window.webkitRequestFileSystem?

  if supportsFileSystem()
    storageMode = 'fileSystem'
  else if supportsLocalStorage()
    storageMode = 'localStorage'

  # debugging
  storageMode = 'fileSystem'

  Persist[storageMode].initialize()

  Persist.save = (filePath, data) ->
    Persist[storageMode].file(filePath, data)

  Persist.find = (filePath) ->
    Persist[storageMode].file(filePath)

  Persist.toString = ->
    Persist[storageMode].toString()
