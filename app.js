require('coffee-script/register');

// Main namespace.
global.JDB = {};

require('./lib/jdb');

module.exports = JDB.Jdb;
