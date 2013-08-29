buster.spec.expose()

describe 'Persist', ->
  it 'exists', ->
    expect(Persist).toBeDefined()

  it 'defines a save method', ->
    expect(Persist.save).toBeDefined()

  it 'defines a find method', ->
    expect(Persist.find).toBeDefined()

  it 'defines a delete method', ->
    expect(Persist.delete).toBeDefined()
