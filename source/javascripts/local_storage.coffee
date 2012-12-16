window.Persist ||= {}

Persist.localStorage =
  file: (path, data) ->
    if data
      localStorage.setItem(filePath, data)
    else
      localStorage.getItem(path)
