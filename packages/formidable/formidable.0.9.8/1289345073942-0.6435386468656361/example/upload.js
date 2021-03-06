require('../test/common');
var http = require('http')
  , sys = require('sys')
  , formidable = require('formidable')
  , server;

server = http.createServer(function(req, res) {
  if (req.url == '/') {
    res.writeHead(200, {'content-type': 'text/html'});
    res.end
      ( '<form action="/upload" enctype="multipart/form-data" method="post">'
      + '<input type="text" name="title"><br>'
      + '<input type="file" name="upload" multiple="multiple"><br>'
      + '<input type="submit" value="Upload">'
      + '</form>'
      )
  } else if (req.url == '/upload') {
    var form = new formidable.IncomingForm()
      , files = []
      , fields = [];

    form.uploadDir = TEST_TMP;

    form
      .addListener('field', function(field, value) {
        p([field, value]);
        fields.push([field, value]);
      })
      .addListener('file', function(field, file) {
        p([field, file]);
        files.push([field, file]);
      })
      .addListener('end', function() {
        puts('-> upload done');
        res.writeHead(200, {'content-type': 'text/plain'});
        res.write('received fields:\n\n '+sys.inspect(fields));
        res.write('\n\n');
        res.end('received files:\n\n '+sys.inspect(files));
      });
    form.parse(req);
  } else {
    res.writeHead(404, {'content-type': 'text/plain'});
    res.end('404');
  }
});
server.listen(TEST_PORT);

sys.puts('listening on http://localhost:'+TEST_PORT+'/');