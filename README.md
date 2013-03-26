# cmfbsub

A Sinatra app which allows Facebook users to add [Campaign Monitor](http://www.campaignmonitor.com/) subscribe forms to their Facebook Pages. Named _cmfbsub_ as some sort of mix between an acronym and an abbreviation for _Campaign Monitor Facebook Subscribe Forms_.

## How it works

Campaign Monitor lists the [Facebook subscribe form](http://www.campaignmonitor.com/integrations/facebook-subscribe-form/) in its list of integrations, where you can find a brief summary of what the app does. The app is available as either a white-labelled version named _Subscribe Form_, or as a Campaign Monitor branded version named _Campaign Monitor Subscribe Form_.

The white-labelled version of the app can be accessed at https://apps.facebook.com/createsend/ and the Campaign Monitor branded version can be accessed at https://apps.facebook.com/campaignmonitor/. These apps are implemented as [Canvas Pages](https://developers.facebook.com/docs/appsonfacebook/tutorial/) and run in an iframe within the Facebook chrome.

So the Sinatra app in this repository is the app which runs in the iframe. The same code is deployed to two different Heroku apps for the two different versions of the app. The white-labelled version of the app runs at https://csfbsub.heroku.com/ and the Campaign Monitor branded version of the app runs at https://cmfbsub.heroku.com/.

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

Run the app locally (runs at [http://localhost:4567/](http://localhost:4567/)):

```
rake
```

There is a Facebook app set up at http://apps.facebook.com/ldevcampaignmonitor/ for testing locally, which will load [http://localhost:4567/](http://localhost:4567/) into the Facebook chrome.

### Deploying

To be able to deploy the app, you will need to be a collaborator on each of the Heroku apps where the app is deployed. In addition to the two production versions of the app (https://apps.facebook.com/campaignmonitor/ and https://apps.facebook.com/createsend/), there is also a development version at https://apps.facebook.com/devcampaignmonitor/ which corresponds to the Heroku app at https://devcmfbsub.heroku.com/. You should always push and test your changes using the development app before pushing the production versions of the app.

You'll need to set up git remotes to point to each version of the app on Heroku, which you can do like so:

```
git remote add devcmfbsub git@heroku.com:devcmfbsub.git
git remote add cmfbsub git@heroku.com:cmfbsub.git
git remote add csfbsub git@heroku.com:csfbsub.git
```

So, you would now push to `devcmfbsub` to deploy the development version of the app, and push to `cmfbsub` and `csfbsub` to deploy both the Campaign Monitor branded and white-label versions of the app.

## Configuration

TODO: Explain Heroku config.
