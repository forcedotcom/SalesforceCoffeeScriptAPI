should = require 'should'
SFDC = require '../SFDC'

describe 'SFDC', ->

  describe '#setSID()', ->
    it 'should set the session Id', ->
      SFDC.sid.should.equal ''
      SFDC.setSID 'mySID'
      SFDC.sid.should.equal 'mySID'

  describe '#setServer()', ->
    it 'should set the server instance Url', ->
      SFDC.server.should.equal ''
      SFDC.setServer 'https://na1.salesforce.com'
      SFDC.server.should.equal 'https://na1.salesforce.com'

  describe '#setContainer()', ->
    it 'should set the container flag', ->
      SFDC.isContainer.should.equal false
      SFDC.setContainer true
      SFDC.isContainer.should.equal true
      SFDC.setContainer false
      SFDC.isContainer.should.equal false

  describe '#logout()', ->
    it 'should reset sid and server when called from within a container', (done) ->
      SFDC.setContainer true
      SFDC.setSID 'mySID'
      SFDC.setServer 'https://na1.salesforce.com'
      SFDC.logout ->
        SFDC.sid.should.equal ''
        SFDC.server.should.equal ''
        done()

  describe '#search()', ->
    it 'should send a 400 for a too short search term', ->
      SFDC.search '1', (result) -> result.status.should.equal 400

  describe '#get()', ->
    it 'should do a get request on the rest API', (done) ->
      SFDC.setContainer true
      SFDC.setServer 'https://na1.salesforce.com'
      SFDC.setSID 'mySID'

      # Mock ajax call
      SFDC.ajax = (url, type, data, callback, ignoreRetry) ->
        url.should.equal 'https://na1.salesforce.com/services/data/v24.0/sobjects/Account/003abc'
        type.should.equal 'GET'
        done()

      SFDC.get SFDC.ACCOUNT, '003abc', (result) ->
        console.log JSON.stringify result
        
    