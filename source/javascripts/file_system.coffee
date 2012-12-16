#= require object_extensions

window.Persist ||= {}

do ->
  fileSystem = null

  requestFS = window.requestFileSystem || window.webkitRequestFileSystem

  createDirectory = (root, path) ->
    # strip off leading /
    path = path.slice(1) if path[0] is '/'

    directories = path.split '/'

    root.getDirectory directories[0], {create: true}, (dir) ->
      newPath = directories.slice(1).join('/')

      return createDirectory(dir, newPath) if directories.length
    , errorHandler

  extension = (fileName) ->
    [prefixes..., ext] = fileName.split('.')

    return ext

  mimeType = (ext) ->
    types =
      coffee: {type: 'application/coffeescript'}
      js: {type: 'text/javascript'}
      txt: {type: 'text/plain'}

    types[ext]

  createFile = (path, data) ->
    # strip off leading /
    path = path.slice(1) if path[0] is '/'

    # make sure all parent directories exist
    [directories..., file] = path.split '/'

    if directories.length
      createDirectory(fileSystem.root, directories.join('/'))

    # now that the directories exist, create the file
    fileSystem.root.getFile path, {create: true}, (file) ->
      file.createWriter (fileWriter) ->
        fileWriter.onwriteend = ->
          console.log 'write completed'
        fileWriter.onerror = (e) ->
          console.log "write failed #{e.toString()}"

        [_..., fileName] = path.split('/')

        ext = extension(fileName)

        blob = new Blob([data], mimeType(ext))

        fileWriter.write(blob)

      , errorHandler
    , errorHandler

    return null

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
      when FileError.TYPE_MISMATCH_ERR
        msg = 'This file extension is not supported'
      else
        msg = 'Unknown Error'

    console.log msg

  defaults =
    type: PERSISTENT
    size: 500 * 1024 * 1024
    successCallback: (fs) ->
      console.log('Opened file system: ' + fs.name)
      fileSystem = fs

      createDirectory(fileSystem.root, 'Documents/Images/Nature/Sky/')
    errorCallback: errorHandler

  window.webkitStorageInfo.requestQuota defaults.type, defaults.size, (grantedBytes) ->
    requestFS(defaults.type, grantedBytes, defaults.successCallback, defaults.errorCallback)
  , (e) ->
    console.log('Error', e)

  Persist.fileSystem =
    file: (path, data) ->
      createFile(path, data)
