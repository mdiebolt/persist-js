#= require object_extensions

window.Persist ||= {}

do ->
  fileSystem = null

  requestFS = window.requestFileSystem || window.webkitRequestFileSystem
  storageInfo = window.storageInfo || window.webkitStorageInfo

  createDirectory = (root, path) ->
    path = normalizePath(path)

    directories = path.split '/'

    root.getDirectory directories[0], {create: true}, (dir) ->
      newPath = directories.slice(1).join('/')

      return createDirectory(dir, newPath) if directories.length
    , errorHandler

  readDirectory = (root, dirPath) ->
    dirPath = normalizePath(dirPath)

    root.getDirectory dirPath, {}, (dir) ->
      reader = dir.createReader()

      reader.readEntries (entries) ->
        results = []

        for entry in entries
          type = 'F' if entry.isFile
          type = 'D' if entry.isDirectory

          results.push(entry.name + '-' + type)

        console.log results.sort()
      , errorHandler
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

  normalizePath = (path) ->
    path = path.slice(1) if path[0] is '/'

    length = path.length

    path = path.substr(0, length - 1) if path[length - 1] is '/'

    return path

  isFile = (string) ->
    string.indexOf('.') > -1

  createFile = (path, data) ->
    path = normalizePath(path)

    return unless path.length

    [directories..., fileName] = path.split '/'

    unless isFile(fileName)
      directories.push(fileName)
      fileName = ''

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

    return data

  readFile = (path) ->
    reader = new FileReader()

    reader.onloadend = (e) ->
      console.log @result

    fileSystem.root.getFile path, {}, (entry) ->
      entry.file (f) ->
        reader.readAsText(f)
      , errorHandler
    , errorHandler

  errorHandler = (e) ->
    errorMap = {}

    errorMap[FileError.QUOTA_EXCEEDED_ERR] = 'File system storage limit exceeded'
    errorMap[FileError.NOT_FOUND_ERR] = 'File or directory not found'
    errorMap[FileError.SECURITY_ERR] = 'Security Error'
    errorMap[FileError.INVALID_MODIFICATION_ERR] = 'Invalid modification'
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

      storageInfo.requestQuota defaults.type, defaults.size, (grantedBytes) ->
        requestFS(defaults.type, grantedBytes, defaults.successCallback, defaults.errorCallback)
      , (e) ->
        console.log('Error', e)
    file: (path, data) ->
      if data?
        createFile(path, data)
      else
        readFile(path)
    list: (dirPath) ->
      readDirectory(fileSystem.root, dirPath)
