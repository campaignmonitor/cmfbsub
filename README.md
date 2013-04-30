# cmfbsub

A Sinatra app which allows Facebook users to add [Campaign Monitor](http://www.campaignmonitor.com/) subscribe forms to their Facebook Pages. Named _cmfbsub_ as some sort of mix between an acronym and an abbreviation for _Campaign Monitor Facebook Subscribe Forms_.

## How it works

Campaign Monitor lists the [Facebook subscribe form](http://www.campaignmonitor.com/integrations/facebook-subscribe-form/) in its list of integrations, where you can find a brief summary of what the app does. The app is available as either a white-labelled version named _Subscribe Form_, or as a Campaign Monitor branded version named _Campaign Monitor Subscribe Form_.

The white-labelled version of the app can be accessed at https://apps.facebook.com/createsend/ and the Campaign Monitor branded version can be accessed at https://apps.facebook.com/campaignmonitor/. These apps are implemented as [Canvas Pages](https://developers.facebook.com/docs/appsonfacebook/tutorial/) and run in an iframe within the Facebook chrome.

So the Sinatra app in this repository is the app which runs in the iframe. The same code is deployed to two different Heroku apps for the two different versions of the app. The white-labelled version of the app runs at https://csfbsub.herokuapp.com/ and the Campaign Monitor branded version of the app runs at https://cmfbsub.herokuapp.com/.

## Developing

Firstly:

```
git clone git@github.com:jdennes/cmfbsub.git && cd cmfbsub/
```

### Working locally

Install dependencies:

```
bundle install
```

There are a few config settings required to run the app which are stored in environment variables. When working locally, config settings are read from a `.env` file (which is obviously entered into `.gitignore`).

Create a `.env` file based on `.env.example`:

```
cp .env.example .env
```

Edit `.env` to include the config settings found on the _Local Dev Campaign Monitor Subscribe_ [admin page](https://developers.facebook.com/apps/195059907238783). You might like to reference the config settings for the development app _devcmfbsub_ on Heroku:

```
heroku config --app devcmfbsub
```

Which will show you something like:

```
=== devcmfbsub Config Vars
APP_API_KEY:                  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
APP_CANVAS_NAME:              devcampaignmonitor
APP_DOMAIN:                   devcmfbsub.herokuapp.com
APP_ID:                       111111111111111
APP_NAME:                     devcmfbsub
APP_SECRET:                   xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
...
```

Finally, run the app locally (runs at [http://localhost:4567/](http://localhost:4567/)):

```
foreman start
```

Then visit the _ldevcmfbsub_ Facebook app at http://apps.facebook.com/ldevcampaignmonitor/ for testing locally, which will load [http://localhost:4567/](http://localhost:4567/) in the iframe inside the Facebook chrome.

### Deploying

To be able to deploy the app, you will need to be a collaborator on each of the Heroku apps where the app is deployed. In addition to the two production versions of the app (https://apps.facebook.com/campaignmonitor/ and https://apps.facebook.com/createsend/), there is also a development version at https://apps.facebook.com/devcampaignmonitor/ which corresponds to the Heroku app at https://devcmfbsub.herokuapp.com/. You should always push and test your changes using the development app before pushing the production versions of the app.

You'll need to set up git remotes to point to each version of the app on Heroku, which you can do like so:

```
git remote add devcmfbsub git@heroku.com:devcmfbsub.git
git remote add cmfbsub git@heroku.com:cmfbsub.git
git remote add csfbsub git@heroku.com:csfbsub.git
```

So, you would now push to `devcmfbsub` to deploy the development version of the app, and push to `cmfbsub` and `csfbsub` to deploy both the Campaign Monitor branded and white-label versions of the app.
