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

  Persist.save = (filePath, data) ->
    Persist[storageMode].file(filePath, data)

  Persist.find = (filePath) ->
    Persist[storageMode].file(filePath)
