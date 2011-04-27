Config = null;

function facebookInit(config) {
  Config = config;

  FB.init({
    appId: Config.appId,
    xfbml: true
  });
  FB.Event.subscribe('auth.sessionChange', handleSessionChange);
  FB.Canvas.setAutoResize();
  if (window == top) { goHome(); }
}

function handleSessionChange(response) {
  if ((Config.userIdOnServer && !response.session) ||
      Config.userIdOnServer != response.session.uid) {
    goHome();
  }
}

function goHome() {
  top.location = 'http://apps.facebook.com/' + Config.canvasName + '/';
}