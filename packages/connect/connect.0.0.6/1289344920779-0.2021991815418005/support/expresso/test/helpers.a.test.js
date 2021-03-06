
var a = require('a')

module.exports = {
    'test upper()': function(assert){
        assert.equal('FOO', a.upper('foo'));
        assert.equal('', a.upper({}));
    },
    
    'test lower()': function(assert){
        assert.equal('foo', a.lower('FOO'));
        // we dont test the other path here,
        // run `make test-cov` to see the coverage
    },
    
    'test lowerAsync()': function(assert, exit){
        n = 0;
        a.lowerAsync('FOO', function(str){
            ++n;
            assert.equal('foo', str);
        });
        
        a.lowerAsync({}, function(str){
            ++n;
            assert.equal('', str);
        });
        
        exit(function(){
            assert.equal(1, n);
        });
    },
    
    'test failures': function(assert){
        assert.ok(false);
    },
    
    'async failure': function(){
        setTimeout(function(){
            throw new Error('failed in timeout');
        }, 100);
    }
}