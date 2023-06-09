# Alpha test

## Preparation

1. Clone this repository, it contains everything you need for testing.
2. At the moment, we're testing spavn-analyzer only in VS Code, a bit later we will add support for
   other editors like Helix, Neovim, Emacs, etc.

### Installing spavn-analyzer

1. The best option for testing would be if you build spavn-analyzer from source, as this way you can
   get the latest version immediately after the changes.
2. After you get the binary, add the path to the folder in PATH so that the editor can find it.
   Optionally, you can pass the path to the binary in the VS Code settings; for these sees the
   instructions in [`code/README.md`](./editors/code/README.md).

When building a binary, keep in mind that by building the prod version, you will get a speedup of
about 30-40%.

### Install plugin for VS Code

1. Before installing a plugin, disable the `V` plugin, as plugins will conflict and work
   incorrectly.
2. Install the plugin using the instructions from [`code/README.md`](./editors/code/README.md).
3. After installing the plugin, restart VS Code.
4. After restarting, if you open a project on V, the analyzer will automatically start indexing the
   project and standard library (only once), this may take some time, depending on the size of the
   project.
   I would be grateful if you could then upload the logs, so I can see the results.
   In VS Code, for some reason, the display of the progress of this process doesn't work, although
   in Neovim, it is displayed correctly. Maybe only my issue, I don't know.
   After the indexing is over, you will notice that the code is highlighted a little differently,
   and go to the definition and other functions will also start to work.
5. If for some reason the analyzer didn't turn on, report it and try to run the command
   `spavn-analyzer: Restart` using the command palette.

### Bug reports

If while the analyzer is running, it suddenly crashes, or some other error occurs, then please
report it in the discord channel (preferred) or in an issue.
Attach the logs you can find in the `~/.config/spavn-analyzer/logs` folder.

If auto-completion, go to definition or some other function doesn't work in some place,
then report it in the discord channel by attaching a link to the project (if it is an open source)
or attach a screenshot so that I have any information to reproduce.
At the moment, there are many such places, the analyzer is developing, and it is difficult to cover
everything at once.

### Supported functions

The following features are currently available:

1. Improved syntax highlighting.
   Basic highlighting in VS Code works on the basis of regular expression grammars, which doesn't
   allow, for example, to understand whether an identifier is a variable, a field, or a function
   reference.
   spavn-analyzer provides two types of additional highlighting:
    1. Highlighting based on the AST tree, this highlighting understands that there are fields of
       structures, that when creating a structure there are fields, and also thanks to it, problems
       in the basic highlighting are corrected.
    2. Highlighting based on resolving, this highlighting understands that there is a variable or
       field in front of it, or a reference to a structure or module name, etc.
2. Autocompletion.
   Auto-completion in various places, methods/fields completion, elements from a module completion,
   etc.
3. Go to the definition.
   Go to the definition of a variable, field, function, structure, etc.
4. Go to type definition.
   Go to the type definition of the element under the cursor, if the cursor is a variable of type
   Foo, then this action will go to the definition of type Foo.
5. Search for reference to the element.
   Search for all places where the element under the cursor is used, for example, if you select a
   function, the analyzer will find all places where this function is called.
6. List of symbols in the current file.
   In the lower left corner there is a collapsible Outline window; it displays all the functions,
   structures, fields, methods, etc. in the current file. When you click on an element, the cursor
   will go to its definition.
7. Renaming inside functions.
   Only renaming of variables/parameters/receivers inside the function is currently working.
   Renaming of all symbols is planned in the future.
8. Inlay hints.
   For some reason, inlay hints don't work in VS Code, but everything works in Neovim.
   Maybe only my issue, I don't know.
   Inline hints currently show variable types, greater than and equals and greater than signs
   for `0 <=..< 10` ranges and `err` variable in `or` blocks.
9. Formatting.
   Formatting with a standard shortcut using `v fmt`
10. Signature help
    Shows float hints for input arguments when calling a function.
