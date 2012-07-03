# Salesforce CoffeeScript API

Client side API written in CoffeeScript to access the Salesforce [REST APIs on Force.com](http://developer.force.com/REST).
The API can be used with the [Salesforce Mobile SDK](http://wiki.developerforce.com/page/MobileSDK) for [iOS](https://github.com/forcedotcom/SalesforceMobileSDK-iOS) and [Android](https://github.com/forcedotcom/SalesforceMobileSDK-Android/).

## Docs

Please see the inline docs for the [RestAPI.coffee](http://forcedotcom.github.com/SalesforceCoffeeScriptAPI/docs/RestAPI.html) class.
To generate the docs you need [Pygment](http://pygments.org) and [docco](http://jashkenas.github.com/docco).

    $ sudo easy_install Pygments
    $ npm install .

Generate the docs:

    $ make docs
    $ open docs/RestAPI.html

## Tests

The tests depend on [Mocha](http://visionmedia.github.com/mocha/), [should](https://github.com/visionmedia/should.js) and [CoffeeScript](http://coffeescript.org). Install the depencies with NPM:

    $ npm install .

Execute the tests using make:

    $ make test