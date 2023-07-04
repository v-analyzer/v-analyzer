#include "tree_sitter/parser.h"
#include <ctype.h>
#include <stdio.h>
#include <string.h>
#include <wctype.h>

//#define DEVELOPMENT 1

// The following code contains definitions and includes that are needed to prevent
// the IDE from complaining about undefined types and functions.
// They are not needed in real external scanner code.
// When developing, uncomment `#define DEVELOPMENT 1`.
#ifdef DEVELOPMENT

#include <stdlib.h>

#define TREE_SITTER_SERIALIZATION_BUFFER_SIZE 1024
#define bool int
#define true 1
#define false 0

typedef uint16_t TSSymbol;

typedef struct TSLexer TSLexer;

struct TSLexer {
    // The current next character in the input stream, represented as a 32-bit unicode code point.
    // The value of lookahead will be 0 at the end of a file.
    int32_t lookahead;

    // The symbol that was recognized.
    // Your scan function should assign to this field one of the values from the TokenType
    // enum, described above.
    TSSymbol result_symbol;

    // A function for advancing to the next character.
    // If you pass true for the second argument, the current character will be
    // treated as whitespace;
    // whitespace won’t be included in the text range associated with tokens emitted
    // by the external scanner.
    void (*advance)(TSLexer *, bool);

    // A function for marking the end of the recognized token.
    // This allows matching tokens that require multiple characters of lookahead.
    // By default, (if you don’t call mark_end), any character that you moved past
    // using the advance function will be included in the size of the token.
    // But once you call mark_end, then any later calls to advance will not increase
    // the size of the returned token.
    // You can call mark_end multiple times to increase the size of the token.
    void (*mark_end)(TSLexer *);

    // A function for querying the current column position of the lexer.
    // It returns the number of codepoints since the start of the current line.
    // The codepoint position is recalculated on every call to this function by
    // reading from the start of the line.
    uint32_t (*get_column)(TSLexer *);

    // A function for checking whether the parser has just skipped some characters
    // in the document.
    // When parsing an embedded document using the ts_parser_set_included_ranges
    // function (described in the multi-language document section), the scanner may
    // want to apply some special behavior when moving to a disjoint part of the document.
    // For example, in EJS documents, the JavaScript parser uses this function to enable
    // inserting automatic semicolon tokens in between the code directives, delimited by <% and %>.
    bool (*is_at_included_range_start)(const TSLexer *);

    // A function for determining whether the lexer is at the end of the file.
    // The value of lookahead will be 0 at the end of a file, but this function should
    // be used instead of checking for that value because the 0 or “NUL” value is also
    // a valid character that could be present in the file being parsed.
    bool (*eof)(const TSLexer *);
};

#endif

enum TokenType {
    AUTOMATIC_SEPARATOR,
    BRACED_INTERPOLATION_OPENING,
    INTERPOLATION_CLOSING,
    C_STRING_OPENING, // = 3
    RAW_STRING_OPENING, // = 4
    STRING_OPENING, // = 5
    STRING_CONTENT,
    STRING_CLOSING,
    COMMENT,
    ERROR_SENTINEL,
    NONE
};

enum StringType {
    SINGLE_QUOTE = NONE + 1, // = 8 + 1 + 1 = 10
    DOUBLE_QUOTE = NONE + 4, // = 8 + 1 + 4 = 13
};

enum StringTokenType {
    C_SINGLE_QUOTE_OPENING = C_STRING_OPENING + SINGLE_QUOTE, // 5 + 10 = 15
    C_DOUBLE_QUOTE_OPENING = C_STRING_OPENING + DOUBLE_QUOTE, // 5 + 13 = 18
    RAW_SINGLE_QUOTE_OPENING = RAW_STRING_OPENING + SINGLE_QUOTE, // 4 + 10 = 14
    RAW_DOUBLE_QUOTE_OPENING = RAW_STRING_OPENING + DOUBLE_QUOTE, // 4 + 13 = 17
    SINGLE_QUOTE_OPENING = STRING_OPENING + SINGLE_QUOTE, // 6 + 10 = 16
    DOUBLE_QUOTE_OPENING = STRING_OPENING + DOUBLE_QUOTE // 6 + 13 = 19
};

bool is_type_single_quote(uint8_t type) {
    uint8_t orig_type = type - SINGLE_QUOTE;
    return orig_type >= C_STRING_OPENING && orig_type <= STRING_OPENING;
}

bool is_type_double_quote(uint8_t type) {
    uint8_t orig_type = type - DOUBLE_QUOTE;
    return orig_type >= C_STRING_OPENING && orig_type <= STRING_OPENING;
}

bool is_type_string(uint8_t type) {
    return is_type_single_quote(type) || is_type_double_quote(type);
}

uint8_t get_final_string_type(uint8_t type) {
    if (is_type_single_quote(type)) {
        return type - SINGLE_QUOTE;
    } else if (is_type_double_quote(type)) {
        return type - DOUBLE_QUOTE;
    } else {
        return type;
    }
}

char expected_end_char(uint8_t type) {
    if (is_type_single_quote(type)) {
        return '\'';
    } else if (is_type_double_quote(type)) {
        return '"';
    } else if (type == BRACED_INTERPOLATION_OPENING) {
        return '}';
    } else {
        return '\0';
    }
}

// Stack
typedef struct {
    unsigned len;
    uint8_t *contents;
} Stack;

Stack *new_stack() {
    Stack *stack = malloc(sizeof(Stack));
    stack->len = 0;
    stack->contents = malloc(TREE_SITTER_SERIALIZATION_BUFFER_SIZE);
    return stack;
}

void stack_push(Stack *stack, uint8_t content) {
    if (stack->len >= TREE_SITTER_SERIALIZATION_BUFFER_SIZE) return;
    stack->contents[stack->len++] = content;
}

uint8_t stack_top(Stack *stack) {
    if (stack->len == 0) return NONE;
    return stack->contents[stack->len - 1];
}

uint8_t stack_pop(Stack *stack) {
    if (stack->len == 0) return NONE;
    return stack->contents[--stack->len];
}

bool stack_empty(Stack *stack) {
    return stack->len == 0;
}

unsigned stack_serialize(Stack *stack, char *buffer) {
    unsigned len = stack->len;
    memcpy(buffer, stack->contents, len);
    return len;
}

void stack_deserialize(Stack *stack, const char *buffer, unsigned len) {
    if (len == 0) {
        stack->len = 0;
        return;
    }
    stack->len = len;
    memcpy(stack->contents, buffer, len);
}

static void free_stack(Stack *stack) {
    free(stack->contents);
    free(stack);
}

static void skip(TSLexer *lexer) {
    lexer->advance(lexer, true);
}

static void advance(TSLexer *lexer) {
    lexer->advance(lexer, false);
}

static void mark_end(TSLexer *lexer) {
    lexer->mark_end(lexer);
}

bool is_end_line(int32_t c) {
    return c == '\r' || c == '\n' || c == '\t';
}

typedef struct {
    bool initialized;
    Stack *tokens;
} Scanner;

void push_type(Scanner *scanner, uint8_t token_type) {
    stack_push(scanner->tokens, token_type);
}

bool scan_interpolation_opening(Scanner *scanner, TSLexer *lexer) {
    advance(lexer);
    if (lexer->lookahead != '{') {
        return false;
    }

    advance(lexer);
    mark_end(lexer);
    lexer->result_symbol = BRACED_INTERPOLATION_OPENING;
    push_type(scanner, lexer->result_symbol);

    return true;
}

bool scan_interpolation_closing(Scanner *scanner, TSLexer *lexer) {
    uint8_t got_top = stack_pop(scanner->tokens);
    if (got_top != BRACED_INTERPOLATION_OPENING) {
        return false;
    }

    advance(lexer);
    lexer->result_symbol = INTERPOLATION_CLOSING;
    return true;
}

bool scan_automatic_separator(Scanner *scanner, TSLexer *lexer) {
    bool is_newline = false;
    bool has_whitespace = false;
    int tab_count = 0;

    while (is_end_line(lexer->lookahead)) {
        if (!has_whitespace) {
            has_whitespace = true;
        }

        if (lexer->lookahead == '\r') {
            advance(lexer);
            mark_end(lexer);
        }

        if (!is_newline && lexer->lookahead == '\n') {
            is_newline = true;
        } else if (lexer->lookahead == '\t') {
            tab_count++;
        }

        advance(lexer);
        mark_end(lexer);
    }

    // true if tab count is 1 or below, false if above 1
    bool needs_to_be_separated = tab_count <= 1;

    // for multi-level blocks. not a good code. should be improved later.
    if (has_whitespace) {
        char got_char = lexer->lookahead;
        switch (got_char) {
            case '|':
            case '&':
                advance(lexer);
                if (lexer->lookahead == got_char || !isalpha(lexer->lookahead)) {
                    needs_to_be_separated = false;
                } else {
                    needs_to_be_separated = true;
                }
                break;
            case '*':
            case '_':
            case '\'':
            case '"':
                needs_to_be_separated = true;
                break;
            case '/':
                advance(lexer);
                if (lexer->lookahead == got_char || lexer->lookahead == '*') {
                    needs_to_be_separated = true;
                } else {
                    needs_to_be_separated = false;
                }
            default:
                if (isalpha(lexer->lookahead)) {
                    needs_to_be_separated = true;
                }
                break;
        }
    }

    if (is_newline && needs_to_be_separated) {
        lexer->result_symbol = AUTOMATIC_SEPARATOR;
        return true;
    }

    return false;
}

bool scan_string_opening(Scanner *scanner, TSLexer *lexer, bool is_quote, bool is_c, bool is_raw) {
    if (is_raw && lexer->lookahead == 'r') {
        lexer->result_symbol = RAW_STRING_OPENING;
        advance(lexer);
    } else if (is_c && lexer->lookahead == 'c') {
        lexer->result_symbol = C_STRING_OPENING;
        advance(lexer);
    } else if (is_quote && (lexer->lookahead == '\'' || lexer->lookahead == '"')) {
        lexer->result_symbol = STRING_OPENING;
    } else {
        return false;
    }

    if (lexer->lookahead == '\'' || lexer->lookahead == '"') {
        uint8_t string_type = lexer->lookahead == '\'' ? SINGLE_QUOTE : DOUBLE_QUOTE;
        advance(lexer);
        push_type(scanner, lexer->result_symbol + string_type);
        return true;
    }

    return false;
}

bool scan_string_content(Scanner *scanner, TSLexer *lexer) {
    uint8_t got_top = stack_top(scanner->tokens);
    if (stack_empty(scanner->tokens) || !is_type_string(got_top)) {
        return false;
    }

    bool is_raw = get_final_string_type(got_top) == RAW_STRING_OPENING;
    bool has_content = false;
    char close_quote = expected_end_char(got_top);

    while (lexer->lookahead) {
        // reached end of string
        if (lexer->lookahead == close_quote) {
            stack_pop(scanner->tokens);
            advance(lexer);
            mark_end(lexer);
            lexer->result_symbol = STRING_CLOSING;
            return true;
        }

        if (!is_raw && lexer->lookahead == '\\') {
            has_content = true;
            advance(lexer);
            if (!lexer->eof(lexer)) {
                advance(lexer);
            }

            continue;
        }

        if (!is_raw && lexer->lookahead == '$') {
            mark_end(lexer);
            advance(lexer);
            lexer->result_symbol = STRING_CONTENT;

            if (lexer->lookahead == '{') {
                return has_content;
            }

            mark_end(lexer);
            return true;
        }

        advance(lexer);
        has_content = true;
    }

    return has_content;
}

bool scan_comment(Scanner *scanner, TSLexer *lexer) {
    advance(lexer);
    if (lexer->lookahead != '/' && lexer->lookahead != '*') {
        return false;
    }

    bool is_multiline = lexer->lookahead == '*';
    int nested_multiline_count = 0;
    advance(lexer);

    while (true) {
        mark_end(lexer);
        if (is_multiline) {
            if (lexer->lookahead == '/') {
                // Handles the "nested" comments (e.g. /* /* comment */ */)
                advance(lexer);
                if (lexer->lookahead == '*') {
                    advance(lexer);
                    mark_end(lexer);
                    nested_multiline_count++;
                }

                continue;
            } else if (lexer->lookahead == '*') {
                advance(lexer);
                if (lexer->lookahead == '/') {
                    advance(lexer);
                    mark_end(lexer);
                    if (nested_multiline_count == 0) {
                        break;
                    }

                    nested_multiline_count--;
                }

                // do mark_end first before advancing
                continue;
            }
        }

        if (!is_multiline && (lexer->lookahead == '\r' || lexer->lookahead == '\n')) {
            break;
        }

        if (lexer->lookahead == '\0') {
            break;
        }

        advance(lexer);
    }

    lexer->result_symbol = COMMENT;
    return true;
}

// Next functions used by Tree-sitter
// See https://tree-sitter.github.io/tree-sitter/creating-parsers#external-scanners

/**
 * Initializes the scanner
 *
 * @return pointer to the scanner
 */
void *tree_sitter_v_external_scanner_create() {
    Scanner *scanner = malloc(sizeof(Scanner));
    scanner->initialized = true;
    scanner->tokens = new_stack();
    return scanner;
}

/**
 * Destroys the scanner and frees memory
 *
 * @param payload scanner created in `tree_sitter_v_external_scanner_create`
 */
void tree_sitter_v_external_scanner_destroy(void *payload) {
    Scanner *scanner = (Scanner *) payload;
    free_stack(scanner->tokens);
    free(scanner);
}

/**
 * Serialize state of the scanner to a buffer
 *
 * @param payload scanner created in `tree_sitter_v_external_scanner_create`
 * @param buffer  buffer to write serialized data to
 * @return count of bytes written to buffer
 */
unsigned tree_sitter_v_external_scanner_serialize(void *payload, char *buffer) {
    Scanner *scanner = (Scanner *) payload;
    unsigned length = stack_serialize(scanner->tokens, buffer);
    return length;
}

/**
 * Deserialize state of the scanner from a buffer written by `tree_sitter_v_external_scanner_serialize`
 *
 * @param payload scanner created in `tree_sitter_v_external_scanner_create`
 * @param buffer  buffer to read serialized data from
 * @param length  length of the buffer
 */
void tree_sitter_v_external_scanner_deserialize(void *payload, const char *buffer, unsigned length) {
    Scanner *scanner = (Scanner *) payload;
    if (length == 0) {
        scanner->initialized = false;
        return;
    }

    scanner->initialized = true;
    stack_deserialize(scanner->tokens, buffer, length);
}

/**
 * Scans the next token
 *
 * @param payload       scanner created in `tree_sitter_v_external_scanner_create`
 * @param lexer         lexer created by tree-sitter
 * @param valid_symbols an array of booleans that indicates which of external tokens are currently
 *                      expected by the parser.
 *                      You should only look for a given token if it is valid according to this array.
 *                      At the same time, you cannot backtrack, so you may need to combine certain pieces
 *                      of logic.
 * @return true if a token was scanned, false otherwise
 */
bool tree_sitter_v_external_scanner_scan(void *payload, TSLexer *lexer, const bool *valid_symbols) {
    if (lexer->lookahead == 0) {
        return false;
    }

    Scanner *scanner = (Scanner *) payload;
    bool is_stack_empty = stack_empty(scanner->tokens);
    uint8_t top = stack_top(scanner->tokens);

    if (is_end_line(lexer->lookahead) && valid_symbols[AUTOMATIC_SEPARATOR] && is_stack_empty) {
        return scan_automatic_separator(scanner, lexer);
    }

    if (is_stack_empty || top == BRACED_INTERPOLATION_OPENING) {
        // a string might follow after some whitespace, so we can't lookahead
        // until we get rid of it
        while (iswspace(lexer->lookahead)) {
            skip(lexer);
        }
    }

    if (!is_type_string(top) && lexer->lookahead == '/' && valid_symbols[COMMENT]) {
        return scan_comment(scanner, lexer);
    }

    bool expect_c_string = valid_symbols[C_STRING_OPENING];
    bool expect_raw_string = valid_symbols[RAW_STRING_OPENING];
    bool expect_string_quote = valid_symbols[STRING_OPENING];

    bool expect_string_start = expect_c_string ||
                               expect_raw_string ||
                               expect_string_quote;

    int stack_about_string = top == BRACED_INTERPOLATION_OPENING ||
                             is_stack_empty;

    if (valid_symbols[ERROR_SENTINEL] && (lexer->lookahead == '\'' || lexer->lookahead == '"' || is_type_string(top))) {
        stack_pop(scanner->tokens);
        return scan_string_opening(
                scanner,
                lexer,
                expect_string_quote,
                expect_c_string,
                expect_raw_string
        );
    }

    if (stack_about_string && expect_string_start) {
        return scan_string_opening(
                scanner,
                lexer,
                expect_string_quote,
                expect_c_string,
                expect_raw_string
        );
    }

    if (lexer->lookahead == '}' && valid_symbols[INTERPOLATION_CLOSING]) {
        return scan_interpolation_closing(scanner, lexer);
    } else if (lexer->lookahead == '$' && valid_symbols[BRACED_INTERPOLATION_OPENING]) {
        return scan_interpolation_opening(scanner, lexer);
    }

    if (valid_symbols[STRING_CONTENT] && scan_string_content(scanner, lexer)) {
        return true;
    }

    return false;
}
