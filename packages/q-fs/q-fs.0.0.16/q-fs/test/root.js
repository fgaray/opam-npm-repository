"use strict";

var Q = require("q/util");
var FS = require("q-fs");
var Root = require("q-fs/root").Fs;
var Mock = require("q-fs/mock").Fs;
var ASSERT = require("assert");

exports['test root mock'] = function (ASSERT, done) {

    // constructs a mock file-system API object
    var mock = Mock({
        "a/b/1": 10,
        "a/b/2": 20,
        "a/b/3": 30
    });

    // constructs a "chrooted" file-system API object
    // around the mock file-system object.
    var chroot = Root(mock, "a/b");

    // grab the file trees of both
    return Q.when(Q.shallow({
        "mock": mock.listTree(),
        "chroot": Q.post(chroot, "listTree")
    }), function (trees) {

        ASSERT.deepEqual(trees.mock, [
            ".", 
            "a",
            "a/b",
            "a/b/1",
            "a/b/2",
            "a/b/3"
        ], 'listTree of mock');

        ASSERT.deepEqual(trees.chroot, [
            ".", 
            "1",
            "2",
            "3"
        ], 'listTree of "chrooted" mock');

    }).then(done, function (error) {
        ASSERT.ok(false, 'error');
        done();
    });
};

if (require.main === module) {
    require("test").run(exports);
}

