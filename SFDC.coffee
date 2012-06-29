class SFDC

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
  Flag if API us used from within Mobile SDK container
  ###
  @isContainer = false

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
  Set the session Id for container usage.
  @param sid Session Id
  ###
  @setSID: (sid) -> SFDC.sid = sid

  ###
  @param server Server Instance Url e.g. https://na1.salesforce.com.
  ###
  @setServer: (server) -> SFDC.server = server

  ###
  @param isContainer Flag if client is inside a container.
  ###
  @setContainer: (isContainer) -> SFDC.isContainer = isContainer

  ###
  @param authenticatorFn Method to refreshSession on session expiration.
  ###
  @setAuthenticator: (authenticatorFn) -> SFDC.authenticator = authenticatorFn

  ###
  Loads a list of MRUs
  @param sobjectType Salesforce object. E.g. 'Contact' or 'Account'
  @param id Optional Id of the record or null to get MRUs
  @param callback Callback function (err, data)
  ###
  @get: (sobjectType, id, callback) ->
    url = SFDC.server
    if SFDC.isContainer
      url += '/services/data/v' + SFDC.apiVersion

    url += '/sobjects/' + sobjectType

    # Add id if a specific resource is requested.
    if id?
      url += '/' + id

    SFDC.ajax url, 'GET', null,  callback


  ###
  @param sobjectType Salesforce object. E.g. 'Contact' or 'Account'
  ###
  @create: (sobjectType, data, callback) ->
    url = SFDC.server
    if SFDC.isContainer
      url += '/services/data/v' + SFDC.apiVersion + '/sobjects/' + sobjectType
    else
      # Add CSRF token for web-app
      data._csrf = $('#csrf_token').attr('value')
      url += '/sobjects/'+sobjectType

    payloadJSON = JSON.stringify data
    SFDC.ajax url, 'POST', payloadJSON, callback

  ###
  @param sobjectType The specified value must be a valid object for your organization. For a complete list of objects, see Standard Objects.
  @param json JSON of the record to be updated
  @param fields JSON object with fields to be updated
  @param callback Callback function (err, result)
  ###
  @update: (sobjectType, json, fields, callback) ->
    type = 'PATCH'
    url = SFDC.server
    if SFDC.isContainer
      url += '/services/data/v' + SFDC.apiVersion + '/sobjects/' + sobjectType + '/' + json.Id
    else
      # Add CSRF token for web-app
      fields._csrf = $('#csrf_token').attr('value')
      # Heroku does not support PATCH so we use POST as a workaround
      type = 'POST'
      url += '/sobjects/'+sobjectType+'/' + json.Id
    
    payloadJSON = JSON.stringify fields
    SFDC.ajax url, type, payloadJSON, callback

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
    url = SFDC.server
    if SFDC.isContainer
      url += '/services/data/v' + SFDC.apiVersion + '/query'
    else
      url += '/relatedContacts'

    SFDC.ajax url, 'GET', {q:query}, callback

  ###
  Performs a Salesforce Object Search Query
  @param searchTerm Search term has to be at least 2 characters long
  @param callback Callback function (err, data)
  ###
  @search: (searchTerm, callback) ->
    if searchTerm? and searchTerm.length >= 2
      url = SFDC.server
      if SFDC.isContainer
        url += '/services/data/v' + SFDC.apiVersion + '/search'
      else
        url += '/search'
      
      searchTerm = searchTerm.replace /([\?&|!{}\[\]\(\)\^~\*:\\"'+-])/g, '\\$1'
      sosq = 'FIND { ' + searchTerm + '* }
              IN Name Fields
              RETURNING contact(name, id), account(name, id)'

      SFDC.ajax url, 'GET', {q:sosq}, callback
    else
      callback {status: 400}

  ###
  @param callback Callback function after logout is complete.
  ###
  @logout: (callback) ->
    if SFDC.isContainer
      SFDC.setSID ''
      SFDC.setServer ''
      callback null
    else
      $.getJSON SFDC.server + '/logout', (data) ->
        callback data

  ###
  AJAX requests
  @param url Url to request
  @param type GET, POST, PATCH
  @param callback Callback function (err, data)
  ###
  @ajax: (url, type, data, callback, ignoreRetry) ->
    logFunction? "ajax #{type}:" + url

    $.ajax
      url: url
      type: type
      data: data
      contentType: 'application/json; charset=utf-8'
      dataType: 'json'
      beforeSend: (xhr) ->
        if SFDC.isContainer
          xhr.setRequestHeader 'Accept', 'application/json'
          xhr.setRequestHeader 'Authorization', 'OAuth ' + SFDC.sid
      success: (data) ->
        logFunction? 'success ' + data
        callback null, data
      error: (err) ->
        verbose = JSON.stringify err
        logFunction? 'error ' + verbose
        if err.status is 401 and not ignoreRetry
          SFDC.authenticator? ->
            SFDC.ajax url, type, data, callback, true
        callback err, null

# Export for client side JavaScript
window?.SFDC = SFDC
# Export for mocha unit test
module?.exports = SFDC
