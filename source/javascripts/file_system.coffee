#= require object_extensions

window.Persist ||= {}

do ->
  fileSystem = null

  requestFS = window.requestFileSystem || window.webkitRequestFileSystem

  errorHandler = (e) ->
    msg = ''

    switch e.code
      when FileError.QUOTA_EXCEEDED_ERR
        msg = 'File system storage limit exceeded'
      when FileError.NOT_FOUND_ERR
        msg = 'File or directory not found'
      when FileError.SECURITY_ERR
        msg = 'SECURITY_ERR'
      when FileError.INVALID_MODIFICATION_ERR
        msg = 'INVALID_MODIFICATION_ERR'
      when FileError.INVALID_STATE_ERR
        msg = 'INVALID_STATE_ERR'
      else
        msg = 'Unknown Error'

    console.log msg

  defaults =
    type: PERSISTENT
    size: 500 * 1024 * 1024
    successCallback: (fs) ->
      console.log('Opened file system: ' + fs.name)
      fileSystem = fs
    errorCallback: errorHandler

  window.webkitStorageInfo.requestQuota defaults.type, defaults.size, (grantedBytes) ->
    requestFS(defaults.type, grantedBytes, defaults.successCallback, defaults.errorCallback)
  , (e) ->
    console.log('Error', e)

  Persist.fileSystem =
    file: (path, data) ->
      if data
        fileSystem.root.getFile path, {create: true}, (fileEntry) ->
          fileEntry.createWriter (fileWriter) ->
            fileWriter.onwriteend = ->
              console.log 'write completed'
            fileWriter.onerror = (e) ->
              console.log "write failed #{e.toString()}"

            blob = new Blob [data, {type: 'text/plain'}]

            fileWriter.write(blob)

          , errorHandler
        , errorHandler
      else
        fileSystem.root.getFile path, {}, (fileEntry) ->
          fileEntry.file (file) ->
             reader = new FileReader()

             reader.onloadend = (e) ->
               console.log(@result)

             reader.readAsText(file)
          , errorHandler
        , errorHandler
