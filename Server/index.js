// Example express application adding the parse-server module to expose Parse
// compatible API routes.

var express = require('express');
var ParseServer = require('parse-server').ParseServer;
var path = require('path');

var databaseUri = process.env.DATABASE_URI || process.env.MONGODB_URI;

if (!databaseUri) {
  console.log('DATABASE_URI not specified, falling back to localhost.');
}

var api = new ParseServer({
  databaseURI: 'mongodb://afterpartydev:yTz23tU4eHjQstz99@ds053186.mlab.com:53186/afterparty-dev',
  cloud: './cloud/main.js',
  appId: 'nXzCDFuTYLWqdbe1zLMJKu4r1wDOWAM1mm678zgZ',
  masterKey: 'T8EhXqKtN0FCT9NfXOIabyU7GiRdgHIf0zh6i5qU',
  serverURL: process.env.SERVER_URL || 'http://localhost:1337/parse',
  auth: { 
    facebook: {
      appIds: ["1377327292516803"] 
    } 
  },
  oauth: { 
    twitter: {
      consumer_key: "C6tnCRjcePUjdKFwqYPuYH",
      consumer_secret: "qqVeqAp2MWhKzdVmJ3LR2S1LIfnlbRIwzdSFcEjXfWC6rWp99T"
    }
  }
});

var app = express();

// Serve static assets from the /public folder
app.use('/public', express.static(path.join(__dirname, '/public')));

// Serve the Parse API on the /parse URL prefix
var mountPath = process.env.PARSE_MOUNT || '/parse';
app.use(mountPath, api);

// Parse Server plays nicely with the rest of your web routes
app.get('/', function(req, res) {
  res.status(200).send('I dream of being a website.  Please star the parse-server repo on GitHub! Did I do it right?');
});

// There will be a test page available on the /test path of your server url
// Remove this before launching your app
app.get('/test', function(req, res) {
  res.sendFile(path.join(__dirname, '/public/test.html'));
});

var port = process.env.PORT || 1337;
var httpServer = require('http').createServer(app);
httpServer.listen(port, function() {
    console.log('parse-server-example running on port ' + port + '.');
});

// This will enable the Live Query real-time server
ParseServer.createLiveQueryServer(httpServer);
