
try {
	require('coffee-script/register');
} catch (e) {}

// Main namespace.
global.JDB = {};

require('./lib/jdb');

module.exports = JDB.Jdb;
