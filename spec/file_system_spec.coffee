buster.spec.expose()

describe 'file system', ->
  it 'defines file method', ->
    expect(Persist.fileSystem.file).toBeDefined()

describe 'Persist.localStorage#file', ->
  describe 'creating', ->
    describe 'in a directory', ->
      it 'creates a file', ->
        Persist.fileSystem.file('data/test.txt', 'file contents')

        file = Persist.fileSystem.file('data/test.txt')

        expect(file).toBeDefined()
