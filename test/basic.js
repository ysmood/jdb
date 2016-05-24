var kit = require('nokit');
var async = kit.async;
var fs = require('fs');
var Jdb = require('../lib/jdb');

var dbPath = 'test/baisc.db';

try {
    fs.unlinkSync(dbPath);
} catch (_error) {}

module.exports = async(function * (it) {
    var jdb = Jdb();

    yield jdb.init({
        dbPath: dbPath,
        compactDBFile: false
    });

    it.describe("Basic", function (it) {

        it('set value', function(tdone) {
            return jdb.exec(function(db) {
                db.doc.a = 10;
                return db.save();
            }, function(err) {
                return tdone(err);
            });
        });
        it('set value via data', function(tdone) {
            return jdb.exec({
                data: 10,
                command: function(db, data) {
                    db.doc.a = data;
                    return db.save();
                },
                callback: function(err) {
                    return tdone(err);
                }
            });
        });
        it('test promise', function(tdone) {
            return jdb.exec(10, function(db, data) {
                return db.send(db.doc.a);
            }).then(function(data) {
                var e;
                try {
                    assert.equal(data, 10);
                    return tdone();
                } catch (_error) {
                    e = _error;
                    return tdone(e);
                }
            });
        });
        it('get value', function() {
            return assert.equal(jdb.doc.a + 1, 11);
        });
        it('compactDBFileSync', function(tdone) {
            "use strict";
            var db, e, str;
            jdb.compactDBFileSync();
            str = fs.readFileSync(dbPath, 'utf8');
            db = eval(str + '; jdb;');
            try {
                assert.equal(db.doc.a, 10);
                return tdone();
            } catch (_error) {
                e = _error;
                return tdone(e);
            }
        });
        it('compactDBFile', function(tdone) {
            "use strict";
            return jdb.exec(function(jdb) {
                jdb.doc.a = 12;
                return jdb.save();
            }).then(function() {
                return jdb.compactDBFile();
            }).then(function() {
                var db, e, str;
                str = fs.readFileSync(dbPath, 'utf8');
                db = eval(str + '; jdb;');
                try {
                    assert.equal(12, db.doc.a);
                    return tdone();
                } catch (_error) {
                    e = _error;
                    return tdone(e);
                }
            });
        });
        return it('close db', function() {
            return jdb.close();
        });

    });
});
