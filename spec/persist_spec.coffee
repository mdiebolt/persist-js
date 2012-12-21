buster.spec.expose()

describe 'Top level namespace', ->
  it 'should exist', ->
    expect(Persist).toBeDefined()

  it 'should define save method', ->
    expect(Persist.save).toBeDefined()

  it 'should define find method', ->
    expect(Persist.find).toBeDefined()
