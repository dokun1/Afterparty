// Example express application adding the parse-server module to expose Parse
// compatible API routes.

var express = require('express');
var ParseServer = require('parse-server').ParseServer;
var path = require('path');
var S3Adapter = require('parse-server').S3Adapter;
var bodyParser = require('body-parser');
var cfenv = require("cfenv")

var appEnv = cfenv.getAppEnv()


var databaseUri = process.env.DATABASE_URI || process.env.MONGODB_URI;

if (!databaseUri) {
  console.log('DATABASE_URI not specified, falling back to localhost.');
}

process.env.NODE_TLS_REJECT_UNAUTHORIZED = "0";
console.log("Recognized server url is: " + process.env.SERVER_URL);
if (process.env.HTTPS) {
  console.log("yes");
} else {
  console.log("no");
}

console.log("The instance URI is " + process.env.CF_INSTANCE_ADDR);

var api = new ParseServer({
  databaseURI: process.env.DATABASE_URI || 'mongodb://localhost:27017/afterparty-local-dev',
  cloud: process.env.CLOUD_CODE_DIR || './cloud/main.js',
  appId: process.env.AFTERPARTY_APP_ID || 'nXzCDFuTYLWqdbe1zLMJKu4r1wDOWAM1mm678zgZ',
  masterKey: process.env.AFTERPARTY_MASTER_KEY || 'T8EhXqKtN0FCT9NfXOIabyU7GiRdgHIf0zh6i5qU',
  filesAdapter: new S3Adapter(
    process.env.AFTERPARTY_S3_ACCESS_KEY || "AKIAJFS5J6CGAQE252CQ",
    process.env.AFTERPARTY_S3_ACCESS_SECRET || "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",
    process.env.AFTERPARTY_S3_BUCKET_NAME || "afterparty-file-storage-dev", {
       directAccess: false,
       region: 'us-east-1'
    }
  ),
  serverURL: process.env.SERVER_URL || 'http://localhost:1337/parse',
  auth: { 
    facebook: {
      appIds: [process.env.FACEBOOK_APP_IDS] 
    } 
  },
  oauth: { 
    twitter: {
      consumer_key: process.env.TWITTER_CONSUMER_KEY,
      consumer_secret: process.env.TWITTER_CONSUMER_SECRET
    }
  }
});

var app = express();
console.log("the url for this is: " + appEnv.url);

// Serve static assets from the /public folder
app.use('/', express.static(path.join(__dirname, '/public')));

// Serve the Parse API on the /parse URL prefix
var mountPath = process.env.PARSE_MOUNT || '/parse';
app.use(mountPath, api);
app.use(bodyParser.json({limit: '20mb'}));
app.use(bodyParser.urlencoded({limit: '20mb', extended: true}));

// There will be a test page available on the /test path of your server url
// Remove this before launching your app
app.get('/test', function(req, res) {
  res.sendFile(path.join(__dirname, '/public/test.html'));
});

var port = process.env.PORT || 1337;
var httpServer = require('http').createServer(app);
httpServer.listen(port, function() {
    console.log('Afterparty running on port ' + port + '.');
});

// This will enable the Live Query real-time server
ParseServer.createLiveQueryServer(httpServer);
