(ERROR) @error
(comment) @comment

(identifier) @variable
(import_path) @variable

(parameter_declaration
  name: (identifier) @parameter)
(function_declaration
  name: (identifier) @function)
(function_declaration
  receiver: (receiver)
  name: (identifier) @method)

(call_expression
 name: (selector_expression
    field: (reference_expression) @method))

(type_reference_expression) @type
(pointer_type) @type
(array_type) @type

(field_name) @property
(selector_expression
  field: (reference_expression) @property)

(int_literal) @number
(interpreted_string_literal) @string
(rune_literal) @string
(escape_sequence) @string.escape

[
 "as"
 "asm"
 "assert"
 ;"atomic"
 "break"
 "const"
 "continue"
 "defer"
 "else"
 "enum"
 "fn"
 "for"
 "$for"
 "go"
 "spawn"
 "goto"
 "if"
 "$if"
 "import"
 "in"
 "!in"
 "interface"
 "is"
 "!is"
 "lock"
 "match"
 "module"
 "mut"
 "or"
 "pub"
 "return"
 "rlock"
 "select"
 "shared"
 "static"
 "struct"
 "type"
 "union"
 "unsafe"
] @keyword

[
 (true)
 (false)
] @boolean

[
 "."
 ","
 ":"
 ";"
] @punctuation.delimiter

[
 "("
 ")"
 "{"
 "}"
 "["
 "]"
 "<"
 ">"
] @punctuation.bracket

(array_creation) @punctuation.bracket

[
 "++"
 "--"

 "+"
 "-"
 "*"
 "/"
 "%"

 "~"
 "&"
 "|"
 "^"

 "!"
 "&&"
 "||"
 "!="

 "<<"
 ">>"

 "<"
 ">"
 "<="
 ">="

 "+="
 "-="
 "*="
 "/="
 "&="
 "|="
 "^="
 "<<="
 ">>="

 "="
 ":="
 "=="

 "?"
 "<-"
 "$"
 ".."
 "..."
] @operator
