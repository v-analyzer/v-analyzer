// MIT License
//
// Copyright (c) 2023-2024 V Open Source Community Association (VOSCA) vosca.dev
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
module server

import lsp
import time
import loglib
import server.tform
import server.inspections
import server.inspections.compiler

pub fn (mut ls LanguageServer) run_diagnostics_in_bg(uri lsp.DocumentUri) {
	ls.bg.queue(fn [mut ls, uri] () {
		ls.run_diagnostics(uri)
	})
}

pub fn (mut ls LanguageServer) run_diagnostics(uri lsp.DocumentUri) {
	watch := time.new_stopwatch(auto_start: true)
	ls.reporter.clear(uri)
	ls.reporter.run_all_inspections(uri)
	ls.reporter.publish(mut ls.writer, uri)

	loglib.with_fields({
		'caller':   @METHOD
		'duration': watch.elapsed().str()
	}).info('Updated diagnostics')
}

pub struct DiagnosticReporter {
mut:
	compiler_path string
	reports       map[lsp.DocumentUri][]inspections.Report
}

fn (mut d DiagnosticReporter) run_all_inspections(uri lsp.DocumentUri) {
	mut source := compiler.CompilerReportsSource{
		compiler_path: d.compiler_path
	}
	d.reports[uri] = source.process(uri)
}

fn (mut d DiagnosticReporter) clear(uri lsp.DocumentUri) {
	d.reports[uri] = []
}

fn (mut d DiagnosticReporter) publish(mut wr ResponseWriter, uri lsp.DocumentUri) {
	reports := d.reports[uri] or { return }
	wr.publish_diagnostics(lsp.PublishDiagnosticsParams{
		uri: uri
		diagnostics: reports.map(d.convert_report(it))
	})
}

fn (_ &DiagnosticReporter) convert_report(report inspections.Report) lsp.Diagnostic {
	possibly_unused := report.message.starts_with('unused')
	possibly_deprecated := report.message.contains('deprecated')
	mut tags := []lsp.DiagnosticTag{}
	if possibly_unused {
		tags << lsp.DiagnosticTag.unnecessary
	}
	if possibly_deprecated {
		tags << lsp.DiagnosticTag.deprecated
	}

	return lsp.Diagnostic{
		range: tform.text_range_to_lsp_range(report.range)
		severity: match report.kind {
			.error { lsp.DiagnosticSeverity.error }
			.warning { lsp.DiagnosticSeverity.warning }
			.notice { lsp.DiagnosticSeverity.information }
		}
		source: 'compiler'
		message: report.message
		tags: tags
	}
}

// publish_diagnostics sends errors, warnings and other diagnostics to the editor
fn (mut wr ResponseWriter) publish_diagnostics(params lsp.PublishDiagnosticsParams) {
	wr.write_notify('textDocument/publishDiagnostics', params)
}
