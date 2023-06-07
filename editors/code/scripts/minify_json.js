#!/usr/bin/env node
// @ts-check
'use strict';

const { exec } = require('child_process');
const { writeFileSync, copyFileSync, renameSync, existsSync } = require('fs');
const { resolve } = require('path');

const jsonFiles = [
	'../syntaxes/v.tmLanguage.json',
	'../syntaxes/v.mod.tmLanguage.json',
	'../language-configuration.json',
	'../vmod-language-configuration.json',
];

const shouldRestore = process.argv.includes('--restore');
jsonFiles.forEach((jsonFile) => {
	const absolutePath = resolve(__dirname, jsonFile);
	const tmpFile = resolve(__dirname, jsonFile.replace('.json', '.tmp.json'));
	if (shouldRestore) {
		renameSync(tmpFile, absolutePath);
	} else {
		if (!existsSync(tmpFile)) {
			copyFileSync(absolutePath, tmpFile);
		}
		exec(`npx json-minify ${absolutePath}`, (error, stdout) => {
			if (error) throw error;
			writeFileSync(absolutePath, stdout);
		});
	}
});
