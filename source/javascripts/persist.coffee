#= require object_extensions

window.Persist ||= {}

do ->
  errorHandler = (e) ->
    msg = ''

    switch e.code
      when FileError.QUOTA_EXCEEDED_ERR
        msg = 'QUOTA_EXCEEDED_ERR'
      when FileError.NOT_FOUND_ERR
        msg = 'NOT_FOUND_ERR'
      when FileError.SECURITY_ERR
        msg = 'SECURITY_ERR'
      when FileError.INVALID_MODIFICATION_ERR
        msg = 'INVALID_MODIFICATION_ERR'
      when FileError.INVALID_STATE_ERR
        msg = 'INVALID_STATE_ERR'
      else
        msg = 'Unknown Error'

    console.log('Error: ' + msg)

  supportsLocalStorage = ->
    window.localStorage?

  supportsFileSystem = ->
    window.requestFileSystem? || window.webkitRequestFileSystem?

  requestFS = window.requestFileSystem || window.webkitRequestFileSystem

  # Public API
  Persist.initialize = (applicationName, options={}) ->
    Object.defaults options,
      type: window.PERSISTENT
      size: 50 * 1024 * 1024
      successCallback: (fs) ->
        console.log('Opened file system: ' + fs.name)
      errorCallback: errorHandler

    requestFS(options.type, options.size, options.successCallback, options.errorCallback)

  Persist.save = (data, filePath) ->
    if supportsFileSystem()
      ;
    if supportsLocalStorage()
      localStorage.setItem(filePath, data)

  Persist.read = (filePath) ->
    if supportsFileSystem()
      ;
    if supportsLocalStorage()
      item = localStorage.getItem(filePath)

  Persist.directory = (filePath) ->
    alert [filePath]

