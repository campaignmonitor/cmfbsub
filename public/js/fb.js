Config = null;

function facebookInit(config) {
  Config = config;
  FB.init({
    appId: Config.appId,
    xfbml: true
  });
  FB.Canvas.setAutoResize();
  if (window == top) { goHome(); }
}

function goHome() {
  top.location = 'https://apps.facebook.com/' + Config.canvasName + '/';
}