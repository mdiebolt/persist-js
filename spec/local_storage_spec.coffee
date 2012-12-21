buster.spec.expose()

describe 'local storage', ->
  it 'should define file method', ->
    expect(Persist.localStorage.file).toBeDefined()

describe 'Persist.localStorage#file', ->
  describe 'retrieving data', ->
    describe 'when a file does not exist', ->
      it 'should return undefined', ->
        expect(Persist.localStorage.file('some/test/file.coffee')).not.toBeDefined()

    describe 'when a file does exist', ->
      before ->
        localStorage.setItem 'test/path', '{"some_file.coffee":true}'

      after ->
        localStorage.removeItem 'test/path'

      it 'should return the file contents', ->
        expect(Persist.localStorage.file('test/path/some_file.coffee')).toBeDefined()

    describe 'when the path is a directory', ->
      describe 'and the directory exists', ->
        before ->
          Persist.localStorage.file('a/directory/file1.txt', 'contents 1')
          Persist.localStorage.file('a/directory/file2.txt', 'contents 2')
          Persist.localStorage.file('a/directory/file3.txt', 'contents 3')

        after ->
          localStorage.removeItem 'a/directory'

        it 'should return the contents of that directory', ->
          dir = Persist.localStorage.file('a/directory')

          expect(dir['file1.txt']).toEqual('contents 1')
          expect(dir['file2.txt']).toEqual('contents 2')
          expect(dir['file3.txt']).toEqual('contents 3')

      describe 'and the directory does not exist', ->
        it 'should return undefined', ->
          dir = expect(Persist.localStorage.file('no/dir')).not.toBeDefined()

  describe 'saving data', ->
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
