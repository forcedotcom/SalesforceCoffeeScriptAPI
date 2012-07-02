should = require 'should'
RestAPI = require '../RestAPI'

describe 'RestAPI', ->

  describe '#setSID()', ->
    it 'should set the session Id', ->
      RestAPI.sid.should.equal ''
      RestAPI.setSID 'mySID'
      RestAPI.sid.should.equal 'mySID'

  describe '#setInstanceUrl()', ->
    it 'should set the instance Url', ->
      RestAPI.instanceUrl.should.equal ''
      RestAPI.setInstanceUrl 'https://na1.salesforce.com'
      RestAPI.instanceUrl.should.equal 'https://na1.salesforce.com'

  describe '#logout()', ->
    it 'should reset sid and instanceUrl when called from within a container', (done) ->
      RestAPI.setSID 'mySID'
      RestAPI.setInstanceUrl 'https://na1.salesforce.com'
      RestAPI.logout ->
        RestAPI.sid.should.equal ''
        RestAPI.instanceUrl.should.equal ''
        done()

  describe '#search()', ->
    it 'should send a 400 for a too short search term', ->
      RestAPI.search '1', (result) -> result.status.should.equal 400

  describe '#get()', ->
    it 'should do a get request on the rest API', (done) ->
      RestAPI.setInstanceUrl 'https://na1.salesforce.com'
      RestAPI.setSID 'mySID'

      # Mock ajax call
      RestAPI.ajax = (url, type, data, callback, ignoreRetry = false) ->
        url.should.equal 'https://na1.salesforce.com/services/data/v24.0/sobjects/Account/001abc'
        type.should.equal 'GET'
        done()

      RestAPI.get RestAPI.ACCOUNT, '001abc'

    it 'should do a get request on the rest API for all items (no id)', (done) ->
      RestAPI.setInstanceUrl 'https://na1.salesforce.com'
      RestAPI.setSID 'mySID'

      # Mock ajax call
      RestAPI.ajax = (url, type, data, callback, ignoreRetry = false) ->
        url.should.equal 'https://na1.salesforce.com/services/data/v24.0/sobjects/Account'
        type.should.equal 'GET'
        done()

      RestAPI.get RestAPI.ACCOUNT

  describe '#create()', ->
    it 'should do a post request on the rest API', (done) ->
      RestAPI.setInstanceUrl 'https://na1.salesforce.com'
      RestAPI.setSID 'mySID'

      payload = { foo:"bar" }

      # Mock ajax call
      RestAPI.ajax = (url, type, data, callback, ignoreRetry = false) ->
        # TODO verify data equals payload
        url.should.equal 'https://na1.salesforce.com/services/data/v24.0/sobjects/Task'
        type.should.equal 'POST'
        done()

      RestAPI.create 'Task', payload

  describe '#update()', ->
    it 'should do a patch request on the rest API', (done) ->
      RestAPI.setInstanceUrl 'https://na1.salesforce.com'
      RestAPI.setSID 'mySID'

      fields = { foo:"bar" }

      # Mock ajax call
      RestAPI.ajax = (url, type, data, callback, ignoreRetry = false) ->
        # TODO verify data equals payload
        url.should.equal 'https://na1.salesforce.com/services/data/v24.0/sobjects/Account/001abc'
        type.should.equal 'PATCH'
        done()

      RestAPI.update 'Account', {Id:'001abc'}, fields
        
    