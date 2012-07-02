# Salesforce CoffeeScript API

Client side API written in CoffeeScript to access the Salesforce [REST APIs on Force.com](http://developer.force.com/REST).
The API can be used with the [Salesforce Mobile SDK](http://wiki.developerforce.com/page/MobileSDK) for [iOS](https://github.com/forcedotcom/SalesforceMobileSDK-iOS) and [Android](https://github.com/forcedotcom/SalesforceMobileSDK-Android/).

## Docs

To create the docs you need [Pygment](http://pygments.org) and [docco](http://jashkenas.github.com/docco).

    $ sudo easy_install Pygments
    $ npm install .

Generate the docs:

    $ make docs

## Tests

The tests depend on [Mocha](http://visionmedia.github.com/mocha/), [should](https://github.com/visionmedia/should.js) and [CoffeeScript](http://coffeescript.org). Install the depencies with NPM:

    $ npm install .

Execute the tests using make:

    $ make test