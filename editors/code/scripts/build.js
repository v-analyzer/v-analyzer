#!/usr/bin/env node
//@ts-check
"use strict";

const esbuild = require("esbuild");

const isWatch = process.argv.includes("--watch");
const isDev = process.argv.includes("--dev");

esbuild
	.context({
		platform: "node",
		entryPoints: ["./src/extension.ts"],
		outdir: "./dist",
		external: ["vscode"],
		format: "cjs",
		sourcemap: "external",
		bundle: true,
		minify: !isDev,
	})
	.then((context) => {
		if (isWatch) {
			context.watch();
		} else {
			context.rebuild().then(() => context.dispose());
		}
	})
	.catch(() => process.exit(1));
