# Salesforce CoffeeScript API

Client side API written in CoffeeScript to access the Salesforce [REST APIs on Force.com](http://developer.force.com/REST).
The API can be used with the [Salesforce Mobile SDK](http://wiki.developerforce.com/page/MobileSDK) for [iOS](https://github.com/forcedotcom/SalesforceMobileSDK-iOS) and [Android](https://github.com/forcedotcom/SalesforceMobileSDK-Android/).

## Usage

### Init

Example for usage inside of PhoneGap:
    
    SFDC.setContainer true
    SFDC.setServer <INSTANCE_URL>
    SFDC.setSID <OAUTH_ACCESS_TOKEN>
    
### Load list of contacts

Load a list of contacts performing a GET request without any Id:
    
    SFDC.get SFDC.CONTACT, null, (result) ->
      console.log 'Loaded ' + result.length + ' contacts'

## Tests

The tests depend on [Mocha](http://visionmedia.github.com/mocha/), [should](https://github.com/visionmedia/should.js) and [CoffeeScript](http://coffeescript.org). Install the depencies with NPM:

    $ npm install .

Execute the tests using make:

    $ make test