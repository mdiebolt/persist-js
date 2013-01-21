# put `describe` and `it` in the global namespace
buster.spec.expose()

describe 'local storage', ->
  before ->
    for k in Object.keys(localStorage)
      localStorage.removeItem(k)

  it 'defines file method', ->
    expect(Persist.localStorage.file).toBeDefined()

describe 'a path string', ->
  describe 'containing an empty string', ->
    it 'does not try to create a file', ->
      Persist.localStorage.file('', 'does not work')

      expect(Persist.localStorage.file('')).not.toBeDefined()

  describe 'containing only a slash', ->
    it 'does not try to create a file', ->
      Persist.localStorage.file('/', 'does not work')

      expect(Persist.localStorage.file('/')).not.toBeDefined()

  describe 'containing a leading slash', ->
    it 'is treated the same as without the slash', ->
      Persist.localStorage.file('/a/leading/slash.txt', 'leading slash')

      leadingSlashFile = Persist.localStorage.file('/a/leading/slash.txt')
      noSlashFile = Persist.localStorage.file('a/leading/slash.txt')

      expect(leadingSlashFile).toEqual(noSlashFile)

      leadingSlashDir = Persist.localStorage.file('/a/leading')
      noSlashDir = Persist.localStorage.file('a/leading')

      expect(leadingSlashDir).toEqual(noSlashDir)

describe 'Persist.localStorage#file', ->
  describe 'retrieving data', ->
    describe 'when a file does not exist', ->
      it 'returns undefined', ->
        expect(Persist.localStorage.file('some/test/file.coffee')).not.toBeDefined()

    describe 'when a file exists', ->
      before ->
        localStorage.setItem 'test/path', '{"some_file.coffee":true}'

      after ->
        localStorage.removeItem 'test/path'

      it 'returns the file contents', ->
        expect(Persist.localStorage.file('test/path/some_file.coffee')).toBeDefined()

    describe 'when the path is a directory', ->
      describe 'and the directory exists', ->
        before ->
          Persist.localStorage.file('a/directory/file1.txt', 'contents 1')
          Persist.localStorage.file('a/directory/file2.txt', 'contents 2')
          Persist.localStorage.file('a/directory/file3.txt', 'contents 3')

        after ->
          localStorage.removeItem 'a/directory'

        it 'returns the contents of that directory', ->
          directory = Persist.localStorage.file('a/directory')

          expect(directory['file1.txt']).toEqual('contents 1')
          expect(directory['file2.txt']).toEqual('contents 2')
          expect(directory['file3.txt']).toEqual('contents 3')

      describe 'and the directory does not exist', ->
        it 'returns undefined', ->
          directory = expect(Persist.localStorage.file('no/dir')).not.toBeDefined()

  describe 'saving data', ->
    describe 'creating an empty directory', ->
      after ->
        localStorage.removeItem('dir')
        localStorage.removeItem('nested/empty/dir')

      it 'works', ->
        Persist.localStorage.file('dir/', '')

        directory = Persist.localStorage.file('dir')

        expect(directory).toBeObject()
        expect(Object.keys(directory).length).toEqual(0)

      it 'works without trailing slash', ->
        Persist.localStorage.file('dir', '')

        directory = Persist.localStorage.file('dir')

        expect(directory).toBeObject()
        expect(Object.keys(directory).length).toEqual(0)

      it 'works with nested directories', ->
        Persist.localStorage.file('nested/empty/dir', '')

        directory = Persist.localStorage.file('nested/empty/dir')

        expect(directory).toBeObject()
        expect(Object.keys(directory).length).toEqual(0)

    describe 'at the root level', ->
      after ->
        localStorage.removeItem 'root.txt'
        localStorage.removeItem 'no_slash.txt'

      it 'works with a leading slash', ->
        Persist.localStorage.file('/root.txt', 'my root data')

        expect(Persist.localStorage.file('/root.txt')).toEqual('my root data')

      it 'works without a leading slash', ->
        Persist.localStorage.file('no_slash.txt', 'no slash data')

        expect(Persist.localStorage.file('no_slash.txt')).toEqual('no slash data')

    describe 'in a directory', ->
      before ->
        Persist.localStorage.file('data/test.txt', 'file contents')

      after ->
        localStorage.removeItem 'data'

      it 'creates a local storage entry', ->
        file = localStorage.getItem('data')

        expect(file).toBeDefined()
        expect(JSON.parse(file)['test.txt']).toEqual('file contents')

      it 'overwrites the previous value', ->
        Persist.localStorage.file('data/test.txt', 'overwritten!')

        file = localStorage.getItem('data')

        expect(JSON.parse(file)['test.txt']).toEqual('overwritten!')

  describe 'removing data', ->
    before ->
      Persist.localStorage.file('a/directory/remove_me.txt', 'Please get rid of me')
      Persist.localStorage.file('a/directory/remove_me_also.txt', 'Me 2')

    after ->
      localStorage.removeItem('a/directory')

    describe 'when the path points to a directory', ->
      it 'deletes the directory', ->
        Persist.localStorage.remove('a/directory')

        expect(Persist.localStorage.file('a/directory')).not.toBeDefined()
    describe 'when the path points to a file', ->
      it 'only deletes the file', ->
        Persist.localStorage.remove('a/directory/remove_me.txt')

        expect(Persist.localStorage.file('a/directory')['remove_me_also.txt']).toEqual('Me 2')
