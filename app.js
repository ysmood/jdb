require('coffee-script/register');

// Main namespace.
global.JDB = {};

switch (process.env.JDB_launch) {
	case 'jworker':
		require('./lib/jworker');
		new JDB.Jworker
		break;

	default:
		require('./lib/jdb');

		module.exports = JDB.Jdb;
		break;
}
