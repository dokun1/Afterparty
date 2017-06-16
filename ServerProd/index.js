// Example express application adding the parse-server module to expose Parse
// compatible API routes.

var express = require('express');
var ParseServer = require('parse-server').ParseServer;
var path = require('path');
var S3Adapter = require('parse-server').S3Adapter;

var databaseUri = process.env.DATABASE_URI || process.env.MONGODB_URI;

if (!databaseUri) {
  console.log('DATABASE_URI not specified, falling back to localhost.');
}

var api = new ParseServer({
  databaseURI: 'mongodb://iosApp:73NM8ith3HFdBAva6@ds149761-a0.mlab.com:49761,ds149761-a1.mlab.com:49761/afterparty-prod?replicaSet=rs-ds149761',
  cloud: './cloud/main.js',
  appId: '5oylONmG3AEYJnzoBv0m4YgOQFGytlAdQO9fEUB2',
  masterKey: 'rEIlG84j9d9eKct1R9Q8jSasuiAKFeRWdbOUvnPc',
  filesAdapter: new S3Adapter(
    "AKIAI6WJS5BZM6KFDIRA",
    "dge8/ntzKfopJtehgmPY3lQON0zxv1rG0MH/H8Zg",
    "afterparty-file-storage", {
       directAccess: false,
       region: 'us-east-1'
    }
  ),
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
app.use('/', express.static(path.join(__dirname, '/public')));

// Serve the Parse API on the /parse URL prefix
var mountPath = process.env.PARSE_MOUNT || '/parse';
app.use(mountPath, api);

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
