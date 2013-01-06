gollum-rack
===========

Rack configuration, middleware, and Gemfile to run the Risk Analytics Reference.

Getting Started
---------------

Clone `reference` wiki repository from Github:

    $ git clone git@github.com:riskanalytics/reference.git

Clone `gollum-rack` from Github:

    $ git clone git@github.com:riskanalytics/gollum-rack.git

Install required Gems:

    $ cd gollum-rack
    $ bundle install

Run Gollum via [[http://puma.io|Puma]]:

    $ GITHUB_KEY=<YOUR_GITHUB_APP_KEY> GITHUB_SECRET=<YOUR_GITHUB_APP_SECRET> WIKI_REPO=../reference bundle exec puma
