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
    errorMap = {}

    errorMap[FireError.QUOTA_EXCEEDED_ERR] = 'File system storage limit exceeded'
    errorMap[FileError.NOT_FOUND_ERR] = 'File or directory not found'
    errorMap[FileError.SECURITY_ERR] = 'Security Error'
    errorMap[FireError.INVALID_MODIFICATION_ERR] = 'Invalid modification'
    errorMap[FileError.TYPE_MISMATCH_ERR] = 'This file extension is not supported'

    if errorMap[e.code]
      msg = errorMap[e.code]
    else
      msg = 'Unknown Error'

    console.log msg

  Persist.fileSystem =
    initialize: ->
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
    file: (path, data) ->
      if data?
        createFile(path, data)
      else
        createDirectory(fileSystem.root, path)
