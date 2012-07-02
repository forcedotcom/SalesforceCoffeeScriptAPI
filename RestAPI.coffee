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
#
# ## Static API to access the Salesforce [REST APIs on Force.com](http://developer.force.com/REST)
# All methods are static so you never have to instantiate RestAPI.
# ## Usage
#
#     RestAPI.setInstanceUrl <INSTANCE_URL>
#     RestAPI.setSID <OAUTH_ACCESS_TOKEN>
#     RestAPI.setAuthenticator (callback) ->
#       # Your code to refresh the SID
#       # When done invoke the callback.
#       callback()
#
# ### Load a list of MRU contacts performing a GET request without any Id:
#    
#     RestAPI.get RestAPI.CONTACT, null, (err, result) ->
#       assertNull err
#       console.log 'Loaded ' + result.length + ' contacts'
#
class RestAPI

  # ### Constants for Salesforce [standard objects](http://www.salesforce.com/us/developer/docs/api/Content/sforce_api_objects_list.htm)
  @CONTACT = 'Contact'
  @ACCOUNT = 'Account'

  # Salesforce API version
  @apiVersion = '24.0'

  # Session Id (Access token retrieved from OAuth flow)
  @sid = ''

  # Salesforce instance Url (e.g. https://na1.salesforce.com)
  @instanceUrl = ''

  # ### Function to refresh the SID
  # The function expects the callback function as a parameter
  # and calls it after the session has been refreshed.
  @authenticator = null

  # ### Log function
  # Default is `console.log`.
  # To disable logging just set it to `null`.
  @logFunction = console.log

  # ### Set the session Id.
  # `sid` Session Id
  @setSID: (sid) -> RestAPI.sid = sid

  # ### Set instance Url
  # `instanceUrl` Server instance Url e.g. https://na1.salesforce.com.
  @setInstanceUrl: (instanceUrl) -> RestAPI.instanceUrl = instanceUrl

  # ### Set authenticator
  # `authenticator` Function to refresh session Id after session expired.
  @setAuthenticator: (authenticator) -> RestAPI.authenticator = authenticator

  # ### Rest Url
  # `endpoint` Optional endpoint like `sobjects/Contact`  
  # Returns Rest Url containing instance url and
  # service endpoint with API version and optional
  # individual endpoint.
  @getRestUrl: (endpoint = '') ->
    return RestAPI.instanceUrl + '/services/data/v' + RestAPI.apiVersion + '/' + endpoint

  # ### GET
  # `sobject` Salesforce object. E.g. 'Contact' or 'Account'  
  # `id` Optional Id of the record or null to get MRUs  
  # `callback` Callback function `(err, data)`
  @get: (sobject, id, callback) ->
    url = RestAPI.getRestUrl 'sobjects/' + sobject

    # Add id if a specific resource is requested.
    url += '/' + id if id?

    RestAPI.ajax url, 'GET', null,  callback



  # ### POST (Create)
  # `sobject` Salesforce object. E.g. 'Task' or 'Note'  
  # `data`  
  # `callback` Callback function `(err, data)`  

  # #### Example
  # sobject: 'Task'
  #
  #     data: {
  #       'WhatId':'001AccountId',
  #       'Subject': 'Some subject',
  #       'Description': 'Description text',
  #       'Status': 'Completed'
  #     }

  # sobject: 'Note'
  #
  #     data: {
  #       'ParentId':'003ContactId',
  #       'Title': 'Some title',
  #       'Body': 'Body text',
  #       'IsPrivate': false
  #     }
  @create: (sobject, data, callback) ->
    url = RestAPI.getRestUrl 'sobjects/' + sobject

    payloadJSON = JSON.stringify data
    RestAPI.ajax url, 'POST', payloadJSON, callback

  # ### PATCH (Update)
  # `sobject` The specified value must be a valid object for your organization.
  # For a complete list of objects see [Standard objects](http://www.salesforce.com/us/developer/docs/api/Content/sforce_api_objects_list.htm).  
  # `json` JSON of the record to be updated  
  # `fields` JSON object with fields to be updated  
  # `callback` Callback function `(err, result)`  
  @update: (sobject, json, fields, callback) ->
    type = 'PATCH'
    url = RestAPI.getRestUrl 'sobjects/' + sobject + '/' + json.Id
  
    payloadJSON = JSON.stringify fields
    RestAPI.ajax url, type, payloadJSON, callback

  # ### Salesforce Object Query
  # `query` [SOQL](http://www.salesforce.com/us/developer/docs/api/Content/sforce_api_calls_soql.htm) query.  
  # `callback` Callback function (err, data)  
  #
  # #### Example
  #
  #     "SELECT Id, Name
  #     FROM Contact
  #     WHERE Account.Id = '" + accountId + "' ORDER BY Name"
  #
  @soql: (query, callback) ->
    url = RestAPI.getRestUrl 'query'
    RestAPI.ajax url, 'GET', {q:query}, callback

  # ### Salesforce Object Search Query
  # `searchTerm` Search term has to be at least 2 characters long  
  # `callback` Callback function (err, data)
  @search: (searchTerm, callback) ->
    if searchTerm? and searchTerm.length >= 2
      url = RestAPI.getRestUrl 'search'
      
      searchTerm = searchTerm.replace /([\?&|!{}\[\]\(\)\^~\*:\\"'+-])/g, '\\$1'
      # @see [SOSL Syntax](http://www.salesforce.com/us/developer/docs/api/Content/sforce_api_calls_sosl_syntax.htm)
      sosl = 'FIND { ' + searchTerm + '* }
              IN Name Fields
              RETURNING contact(name, id), account(name, id)'

      RestAPI.ajax url, 'GET', {q:sosl}, callback
    else
      callback {status: 400}

  # ### Logout
  # Resets the session Id and instance Url.
  # `callback` Callback function after logout is complete.
  @logout: (callback) ->
    RestAPI.setSID ''
    RestAPI.setInstanceUrl ''
    callback null

  # ### AJAX request using JQuery
  # `url` Url to request  
  # `type` GET, POST, PATCH, DELETE  
  # `callback` Callback function (err, data)  
  # `ignoreRetry` Internal flag used to only try refreshing SID once.
  @ajax: (url, type, data, callback, ignoreRetry = false) ->

    if logFunction?
      logLine = "ajax #{type}: #{url}"
      logLine += JSON.strinify data if data
      logFunction logLine

    $.ajax
      url: url
      type: type
      data: data
      contentType: 'application/json; charset=utf-8'
      dataType: 'json'
      # Sign the call with the OAuth header.
      beforeSend: (xhr) ->
        xhr.setRequestHeader 'Accept', 'application/json'
        xhr.setRequestHeader 'Authorization', 'OAuth ' + RestAPI.sid
      success: (data) ->
        logFunction? 'success ' + data
        callback null, data
      error: (err) ->
        logFunction? 'error ' + JSON.stringify err
        # When a 401 is retrieved we expect it to be
        # a _session expiration_ so we trigger the `authenticator`
        # when available. This gets only triggered if ignoreRetry
        # is set to false to avoid an infinite loop.
        if err.status is 401 and not ignoreRetry
          RestAPI.authenticator? ->
            RestAPI.ajax url, type, data, callback, true
        callback err, null

# Export for client side JavaScript
window?.RestAPI = RestAPI
# Export for mocha unit test
module?.exports = RestAPI
