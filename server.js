var express = require('express');
var app = express();

// all environments
app.configure(function() {
  app.set('port', process.env.PORT || 3500);
  app.set('views', __dirname + '/views');
  app.set('view engine', 'jade');

  app.use(express.static(__dirname + '/public'));
});

app.get('/', function(req, res) {
  res.render('index', { title: 'Home' });
});

app.listen(app.get('port'));
console.log('Listening on port ' + app.get('port'));
