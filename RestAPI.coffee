class RestAPI

  ###
  Constants for Salesforce standard objects
  @see http://www.salesforce.com/us/developer/docs/api/Content/sforce_api_objects_list.htm
  ###
  @CONTACT = 'Contact'
  @ACCOUNT = 'Account'

  ###
  Salesforce API version
  ###
  @apiVersion = '24.0'

  ###
  Session Id (Access token retrieved from OAuth flow)
  ###
  @sid = ''

  ###
  Server instance Url (e.g. https://na1.salesforce.com)
  ###
  @server = ''

  ###
  Function to refresh the SID
  ###
  @authenticator = null

  ###
  Log function. Default is console.log.
  To disable logging just set it to null.
  ###
  @logFunction = console.log

  ###
  Set the session Id.
  @param sid Session Id
  ###
  @setSID: (sid) -> RestAPI.sid = sid

  ###
  @param server Server Instance Url e.g. https://na1.salesforce.com.
  ###
  @setServer: (server) -> RestAPI.server = server

  ###
  @param authenticator Function to refresh SID after session expired.
  ###
  @setAuthenticator: (authenticator) -> RestAPI.authenticator = authenticator

  ###
  Loads a list of MRUs
  @param sobject Salesforce object. E.g. 'Contact' or 'Account'
  @param id Optional Id of the record or null to get MRUs
  @param callback Callback function (err, data)
  ###
  @get: (sobject, id, callback) ->
    url = RestAPI.server
    url += '/services/data/v' + RestAPI.apiVersion + '/sobjects/' + sobject

    # Add id if a specific resource is requested.
    if id?
      url += '/' + id

    RestAPI.ajax url, 'GET', null,  callback


  ###
  @param sobject Salesforce object. E.g. 'Task' or 'Note'
  @param data
  @param callback Callback function (err, data)

  Example
  sobject: 'Task'
  data: {
    'WhatId':'001AccountId',
    'Subject': 'Some subject',
    'Description': 'Description text',
    'Status': 'Completed'
  }

  sobject: 'Note'
  data: {
    'ParentId':'003ContactId',
    'Title': 'Some title',
    'Body': 'Body text',
    'IsPrivate': false
  }
  ###
  @create: (sobject, data, callback) ->
    url = RestAPI.server
    url += '/services/data/v' + RestAPI.apiVersion + '/sobjects/' + sobject

    payloadJSON = JSON.stringify data
    RestAPI.ajax url, 'POST', payloadJSON, callback

  ###
  @param sobject The specified value must be a valid object for your organization. For a complete list of objects, see Standard Objects.
  @param json JSON of the record to be updated
  @param fields JSON object with fields to be updated
  @param callback Callback function (err, result)
  ###
  @update: (sobject, json, fields, callback) ->
    type = 'PATCH'
    url = RestAPI.server
    url += '/services/data/v' + RestAPI.apiVersion + '/sobjects/' + sobject + '/' + json.Id
  
    payloadJSON = JSON.stringify fields
    RestAPI.ajax url, type, payloadJSON, callback

  ###
  Performs a Salesforce Object Query
  @param query SOQL query.
  @pram callback Callback function (err, data)
  @see http://www.salesforce.com/us/developer/docs/api/Content/sforce_api_calls_soql.htm
  Example: "SELECT Id, Name
            FROM Contact
            WHERE Account.Id = '" + accountId + "' ORDER BY Name"
  ###
  @soql: (query, callback) ->
    url = RestAPI.server
    url += '/services/data/v' + RestAPI.apiVersion + '/query'
    RestAPI.ajax url, 'GET', {q:query}, callback

  ###
  Performs a Salesforce Object Search Query
  @param searchTerm Search term has to be at least 2 characters long
  @param callback Callback function (err, data)
  ###
  @search: (searchTerm, callback) ->
    if searchTerm? and searchTerm.length >= 2
      url = RestAPI.server
      url += '/services/data/v' + RestAPI.apiVersion + '/search'
      
      searchTerm = searchTerm.replace /([\?&|!{}\[\]\(\)\^~\*:\\"'+-])/g, '\\$1'
      sosq = 'FIND { ' + searchTerm + '* }
              IN Name Fields
              RETURNING contact(name, id), account(name, id)'

      RestAPI.ajax url, 'GET', {q:sosq}, callback
    else
      callback {status: 400}

  ###
  @param callback Callback function after logout is complete.
  ###
  @logout: (callback) ->
    RestAPI.setSID ''
    RestAPI.setServer ''
    callback null

  ###
  AJAX requests
  @param url Url to request
  @param type GET, POST, PATCH
  @param callback Callback function (err, data)
  ###
  @ajax: (url, type, data, callback, ignoreRetry = false) ->
    logFunction? "ajax #{type}:" + url

    $.ajax
      url: url
      type: type
      data: data
      contentType: 'application/json; charset=utf-8'
      dataType: 'json'
      beforeSend: (xhr) ->
        xhr.setRequestHeader 'Accept', 'application/json'
        xhr.setRequestHeader 'Authorization', 'OAuth ' + RestAPI.sid
      success: (data) ->
        logFunction? 'success ' + data
        callback null, data
      error: (err) ->
        verbose = JSON.stringify err
        logFunction? 'error ' + verbose
        if err.status is 401 and not ignoreRetry
          RestAPI.authenticator? ->
            RestAPI.ajax url, type, data, callback, true
        callback err, null

# Export for client side JavaScript
window?.RestAPI = RestAPI
# Export for mocha unit test
module?.exports = RestAPI
