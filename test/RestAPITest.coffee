# Copyright (c) 2012, salesforce.com, inc.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without modification, are permitted provided
# that the following conditions are met:
#
#    Redistributions of source code must retain the above copyright notice, this list of conditions and the
#    following disclaimer.
#
#    Redistributions in binary form must reproduce the above copyright notice, this list of conditions and
#    the following disclaimer in the documentation and/or other materials provided with the distribution.
#
#    Neither the name of salesforce.com, inc. nor the names of its contributors may be used to endorse or
#    promote products derived from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED
# WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
# PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
# TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

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
        
    