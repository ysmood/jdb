#!/usr/bin/env node

try {
	require('coffee-script/register');
} catch (e) {}

require('../lib/server')

new JDB.Server
