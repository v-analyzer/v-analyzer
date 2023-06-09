module index

import analyzer.psi

// FileIndex describes the cache of a single file.
// By splitting the cache into files, we can index files in parallel
// without the need for synchronization.
[heap]
pub struct FileIndex {
pub mut:
	filepath string // absolute path to the file
	kind     IndexingRootKind // root where the file is located
	// file_last_modified stores the time the file was last modified
	//
	// Thanks to it, while checking the cache, we can understand whether the
	// file has been changed or not.
	// If the file has been modified, then we reindex the file.
	file_last_modified i64
	// module_name is the name of the module defined in the file (`module name`),
	// if not defined then the empty string.
	module_name string
	// module_fqn is the fully qualified name of the module from the root, eg `foo.bar` or `foo.bar.baz`,
	//  if no module is defined then the empty string.
	module_fqn string
	// stub_list is a list of all stubs in the file.
	// Storing stubs as a table makes it easy and compact to save them to disk and load them back.
	stub_list &psi.StubList
	// sink describes the indexed stubs of the current file.
	// So, for example, by the '.functions' key, you can get the stubs of all functions defined inside the current file.
	// See also 'StubIndexKey'.
	sink &psi.StubIndexSink
}
