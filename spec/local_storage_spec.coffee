# put `describe` and `it` in the global namespace
buster.spec.expose()

describe 'local storage', ->
  before ->
    localStorage.clear()

    @store = Persist.localStorage

  it 'defines file method', ->
    expect(@store.file).toBeDefined()

  describe "complex types", ->
    it "stores nested objects", ->
      @store.file("/dir/my_file.txt", {a: 1, b: 2, nested: {c: 3, d: 'Deep'}})

      file = @store.file("dir/my_file.txt")

      expect(file.a).toEqual(1)
      expect(file.b).toEqual(2)

      expect(file.nested.c).toEqual(3)
      expect(file.nested.d).toEqual("Deep")

  describe 'a path string', ->
    describe 'that is empty', ->
      it 'does not try to create a file', ->
        @store.file('', 'does not work')

        expect(@store.file('')).not.toBeDefined()
        expect(localStorage.length).toEqual(0)

    describe 'containing only a slash', ->
      it 'does not try to create a file', ->
        @store.file('/', 'does not work')

        expect(@store.file('/')).not.toBeDefined()
        expect(localStorage.length).toEqual(0)

    describe 'containing a leading slash', ->
      describe 'files with a leading slash in the path', ->
        it 'is treated the same as a file without the slash', ->
          @store.file('/a/leading/slash.txt', 'leading slash')

          leadingSlash = @store.file('/a/leading/slash.txt')
          noSlash = @store.file('a/leading/slash.txt')

          expect(leadingSlash).toEqual(noSlash)

      describe 'directories with a leading slash in the path', ->
        it 'is treated the same as a directory without the slash', ->
          @store.file('/a/leading/slash.txt', 'leading slash')

          leadingSlash = @store.file('/a/leading')
          noSlash = @store.file('a/leading')

          expect(leadingSlash).toEqual(noSlash)

  describe '@store#file', ->
    describe 'retrieving data', ->
      describe 'when a file does not exist', ->
        it 'returns undefined', ->
          expect(@store.file('some/test/file.coffee')).not.toBeDefined()

      describe 'when a file exists', ->
        before ->
          localStorage.setItem 'test/path', '{"some_file.coffee":true}'

        after ->
          localStorage.removeItem 'test/path'

        it 'returns the file contents', ->
          expect(@store.file('test/path/some_file.coffee')).toBeDefined()

      describe 'when the path is a directory', ->
        describe 'and the directory exists', ->
          before ->
            @store.file('a/directory/file1.txt', 'contents 1')
            @store.file('a/directory/file2.txt', 'contents 2')
            @store.file('a/directory/file3.txt', 'contents 3')

          after ->
            localStorage.removeItem 'a/directory'

          it 'returns the contents of that directory', ->
            directory = @store.file('a/directory')

            expect(directory['file1.txt']).toEqual('contents 1')
            expect(directory['file2.txt']).toEqual('contents 2')
            expect(directory['file3.txt']).toEqual('contents 3')

        describe 'and the directory does not exist', ->
          it 'returns undefined', ->
            directory = expect(@store.file('no/dir')).not.toBeDefined()

    describe 'creating', ->
      describe 'an empty directory', ->
        after ->
          localStorage.removeItem('dir')
          localStorage.removeItem('nested/empty/dir')

        it 'works', ->
          @store.file('dir/', '')

          directory = @store.file('dir')

          expect(directory).toBeObject()
          expect(Object.keys(directory).length).toEqual(0)

        it 'works without trailing slash', ->
          @store.file('dir', '')

          directory = @store.file('dir')

          expect(directory).toBeObject()
          expect(Object.keys(directory).length).toEqual(0)

        it 'works with nested directories', ->
          @store.file('nested/empty/dir', '')

          directory = @store.file('nested/empty/dir')

          expect(directory).toBeObject()
          expect(Object.keys(directory).length).toEqual(0)

      describe 'at the root level', ->
        after ->
          localStorage.removeItem 'root.txt'
          localStorage.removeItem 'no_slash.txt'

        it 'works with a leading slash', ->
          @store.file('/root.txt', 'my root data')

          expect(@store.file('/root.txt')).toEqual('my root data')

        it 'works without a leading slash', ->
          @store.file('no_slash.txt', 'no slash data')

          expect(@store.file('no_slash.txt')).toEqual('no slash data')

      describe 'in a directory', ->
        before ->
          @store.file('data/test.txt', 'file contents')

        after ->
          localStorage.removeItem 'data'

        it 'creates a local storage entry', ->
          file = localStorage.getItem('data')

          expect(file).toBeDefined()
          expect(JSON.parse(file)['test.txt']).toEqual('file contents')

        it 'overwrites the previous value', ->
          @store.file('data/test.txt', 'overwritten!')

          file = localStorage.getItem('data')

          expect(JSON.parse(file)['test.txt']).toEqual('overwritten!')

    describe 'removing data', ->
      before ->
        @store.file('a/directory/remove_me.txt', 'Please get rid of me')
        @store.file('a/directory/remove_me_also.txt', 'Me 2')

      after ->
        localStorage.removeItem('a/directory')

      describe 'when the path points to a directory', ->
        it 'deletes the directory', ->
          @store.remove('a/directory')

          expect(@store.file('a/directory')).not.toBeDefined()

      describe 'when the path points to a file', ->
        it 'only deletes the file', ->
          @store.remove('a/directory/remove_me.txt')

          expect(@store.file('a/directory')['remove_me_also.txt']).toEqual('Me 2')
