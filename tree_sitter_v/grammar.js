const PREC = {
  attributes: 10,
  match_arm_type: 9,
  type_initializer: 8,
  primary: 7,
  unary: 6,
  multiplicative: 5,
  additive: 4,
  comparative: 3,
  and: 2,
  or: 1,
  resolve: 1,
  composite_literal: -1,
};

const multiplicative_operators = ['*', '/', '%', '<<', '>>', '>>>', '&', '&^'];
const additive_operators = ['+', '-', '|', '^'];
const comparative_operators = ['==', '!=', '<', '<=', '>', '>=', 'in', '!in'];
const assignment_operators = multiplicative_operators
  .concat(additive_operators)
  .map((operator) => operator + '=')
  .concat('=');
const unary_operators = ['+', '-', '!', '~', '^', '*', '&', '<-'];
const overridable_operators = [
  '+', '-', '*', '/', '%', '<', '>', '==', '!=', '<=', '>=',
].map((operator) => token(operator));

const terminator = choice('\n', '\r', '\r\n');

const unicode_digit = /[0-9]/;
const unicode_letter = /[a-zA-Zα-ωΑ-Ωµ]/;

const letter = choice(unicode_letter, '_');

const hex_digit = /[0-9a-fA-F]/;
const octal_digit = /[0-7]/;
const decimal_digit = /[0-9]/;
const binary_digit = /[01]/;

const hex_digits = seq(hex_digit, repeat(seq(optional('_'), hex_digit)));
const octal_digits = seq(octal_digit, repeat(seq(optional('_'), octal_digit)));
const decimal_digits = seq(decimal_digit, repeat(seq(optional('_'), decimal_digit)));
const binary_digits = seq(binary_digit, repeat(seq(optional('_'), binary_digit)));

const hex_literal = seq('0', choice('x', 'X'), optional('_'), hex_digits);
const octal_literal = seq('0', optional(choice('o', 'O')), optional('_'), octal_digits);
const decimal_literal = choice('0', seq(/[1-9]/, optional(seq(optional('_'), decimal_digits))));
const binary_literal = seq('0', choice('b', 'B'), optional('_'), binary_digits);

const int_literal = choice(binary_literal, decimal_literal, octal_literal, hex_literal);

const decimal_exponent = seq(choice('e', 'E'), optional(choice('+', '-')), decimal_digits);
const decimal_float_literal = choice(
  seq(decimal_digits, '.', decimal_digits, optional(decimal_exponent)),
  seq(decimal_digits, decimal_exponent),
  seq('.', decimal_digits, optional(decimal_exponent)),
);

const hex_exponent = seq(choice('p', 'P'), optional(choice('+', '-')), decimal_digits);
const hex_mantissa = choice(
  seq(optional('_'), hex_digits, '.', optional(hex_digits)),
  seq(optional('_'), hex_digits),
  seq('.', hex_digits),
);
const hex_float_literal = seq('0', choice('x', 'X'), hex_mantissa, hex_exponent);
const float_literal = choice(decimal_float_literal, hex_float_literal);

const format_flag = token(/[bgGeEfFcdoxXpsS]/);

const semi = choice(terminator, ';');
const list_separator = choice(semi, ',');

module.exports = grammar({
  name: 'v',

  extras: ($) => [$.comment, /\s/],

  word: ($) => $.identifier,

  externals: ($) => [
    $._automatic_separator,
    $._braced_interpolation_opening,
    $._unbraced_interpolation_opening,
    $._interpolation_closing,
    $._c_string_opening,
    $._raw_string_opening,
    $._string_opening,
    $._string_content,
    $._string_closing,
    $._comment,
  ],

  inline: ($) => [
    $._type,
    $._string_literal,
    $._top_level_declaration,
    $._non_empty_array,
  ],

  supertypes: ($) => [
    $._expression,
    $._type,
    $._statement,
    $._top_level_declaration,
    $._expression_with_blocks,
  ],

  conflicts: ($) => [
    [$.qualified_type, $._expression],
    [$.fixed_array_type, $.literal],
    [$.fixed_array_type, $._expression],
    [$._binded_type, $._expression],
    [$._binded_type, $._expression_without_blocks],
    [$.none, $.none_type],
    [$.reference_expression, $.type_reference_expression],
  ],

  rules: {
    source_file: ($) => seq(
      optional($.module_clause),
      optional($.import_list),
      repeat(
        choice(
          seq($._top_level_declaration, optional(semi)),
          seq($._statement, optional(semi)),
        ),
      ),
    ),

    // http://stackoverflow.com/questions/13014947/regex-to-match-a-c-style-multiline-comment/36328890#36328890
    comment: ($) => $._comment,

    module_clause: ($) => seq(
      optional($.attributes),
      'module',
      $.identifier,
    ),

    import_list: ($) => repeat1($.import_declaration),

    import_declaration: ($) => seq('import', $.import_spec, semi),

    import_spec: ($) => seq(
      $.import_path,
      optional($.import_alias),
      optional($.selective_import_list),
    ),

    // foo.bar.baz
    import_path: ($) => seq($._import_name, repeat(seq('.', $._import_name))),

    // foo
    _import_name: ($) => $.identifier,

    // foo as bar
    //     ^^^^^^
    import_alias: ($) => seq('as', $.identifier),

    // { foo, bar }
    selective_import_list: ($) => seq('{', $._import_symbols_list, '}'),

    // foo, bar
    _import_symbols_list: ($) => seq(comma_or_semi_sep1($.reference_expression), optional(list_separator)),

    // ==================== TOP LEVEL DECLARATIONS ====================

    _top_level_declaration: ($) => choice(
      $.const_declaration,
      $.global_var_declaration,
      $.type_declaration,
      $.function_declaration,
      $.struct_declaration,
      $.enum_declaration,
      $.interface_declaration,
    ),

    const_declaration: ($) => seq(
      field('attributes', optional($.attributes)),
      optional($.visibility_modifiers),
      'const',
      choice(
        $.const_definition,
        seq('(', repeat(seq($.const_definition, semi)), ')'),
      ),
    ),

    const_definition: ($) => seq(
      field('name', $.identifier),
      '=',
      field('value', $._expression),
    ),

    global_var_declaration: ($) => seq(
      field('attributes', optional($.attributes)),
      '__global',
      choice(
        $.global_var_definition,
        seq('(', repeat(seq($.global_var_definition, semi)), ')'),
      ),
    ),

    global_var_definition: ($) => seq(
      field('name', $.identifier),
      choice(
        $._type,
        $._global_var_value,
      ),
    ),

    _global_var_value: ($) => seq('=', field('value', $._expression)),

    type_declaration: ($) => seq(
      optional($.visibility_modifiers),
      'type',
      field('name', $.identifier),
      field('generic_parameters', optional($.generic_parameters)),
      '=',
      field('types', $.type_union_list),
    ),

    // int | string | Foo
    type_union_list: ($) => seq($.plain_type, repeat(seq('|', $.plain_type))),

    function_declaration: ($) => prec.right(PREC.resolve,
      seq(
        field('attributes', optional($.attributes)),
        optional($.visibility_modifiers),
        'fn',
        field('receiver', optional($.receiver)),
        field('name', $._function_name),
        field('generic_parameters', optional($.generic_parameters)),
        field('signature', $.signature),
        field('body', optional($.block)),
      )),

    _function_name: ($) => choice($.binded_identifier, $.identifier, $.overridable_operator),

    overridable_operator: () => choice(...overridable_operators),

    receiver: ($) => prec(PREC.primary, seq(
      '(',
      seq(
        field('mutability', optional($.mutability_modifiers)),
        field('name', $.identifier),
        field('type', $.plain_type),
      ),
      ')',
    )),

    signature: ($) => prec.right(seq(
      field(
        'parameters',
        choice($.parameter_list, $.type_only_parameter_list),
      ),
      field('result', optional($._type)),
    )),

    parameter_list: ($) =>
      prec(PREC.resolve, seq('(', comma_sep($.parameter_declaration), ')')),

    parameter_declaration: ($) => seq(
      field('mutability', optional($.mutability_modifiers)),
      field('name', $.identifier),
      optional(field('variadic', '...')),
      field('type', choice($.plain_type, $.option_type)),
    ),

    type_only_parameter_list: ($) =>
      seq('(', comma_sep($.type_only_parameter_declaration), ')'),

    type_only_parameter_declaration: ($) => seq(
      optional($.mutability_modifiers),
      optional(field('variadic', '...')),
      field('type', choice($.plain_type, $.option_type)),
    ),

    // fn foo[T, T2]() {}
    //       ^^^^^^^
    generic_parameters: ($) => prec(PREC.resolve, seq(
      choice(token.immediate('['), token.immediate('<')),
      comma_sep1($.generic_parameter),
      optional(','),
      choice(']', '>'),
    )),

    generic_parameter: ($) => $.identifier,


    struct_declaration: ($) => seq(
      field('attributes', optional($.attributes)),
      optional($.visibility_modifiers),
      choice('struct', 'union'),
      field('name', choice($.identifier, $.binded_identifier)),
      field('generic_parameters', optional($.generic_parameters)),
      $._struct_body,
    ),

    _struct_body: ($) => seq(
      '{',
      repeat(
        choice(
          seq($.struct_field_scope, optional(terminator)),
          seq($.struct_field_declaration, optional(terminator)),
        ),
      ),
      '}',
    ),

    // pub:
    // mut:
    // pub mut:
    // __global:
    struct_field_scope: () => seq(
      choice(
        'pub',
        'mut',
        seq('pub', 'mut'),
        '__global',
      ),
      ':',
    ),

    struct_field_declaration: ($) =>
      choice(
        $._struct_field_definition,
        $.embedded_definition,
      ),

    _struct_field_definition: ($) => prec.right(PREC.type_initializer, seq(
      field('name', $.identifier),
      field('type', choice($.plain_type, $.option_type)),
      field('attributes', optional($.attribute)),
      optional(seq('=', field('default_value', $._expression))),
    )),

    embedded_definition: ($) => prec.right(PREC.unary, $.plain_type),


    enum_declaration: ($) => seq(
      field('attributes', optional($.attributes)),
      optional($.visibility_modifiers),
      'enum',
      field('name', $.identifier),
      optional($.enum_backed_type),
      $._enum_body,
    ),

    enum_backed_type: ($) => seq('as', $.plain_type),

    _enum_body: ($) => seq(
      '{',
      repeat(seq($.enum_field_definition, optional(terminator))),
      '}',
    ),

    enum_field_definition: ($) => seq(
      field('name', $.identifier),
      optional(seq('=', field('value', $._expression))),
      field('attributes', optional($.attribute)),
    ),


    interface_declaration: ($) => seq(
      field('attributes', optional($.attributes)),
      optional($.visibility_modifiers),
      'interface',
      field('name', choice($.identifier, $.binded_identifier)),
      field('generic_parameters', optional($.generic_parameters)),
      $._interface_body,
    ),

    _interface_body: ($) => seq(
      '{',
      repeat(
        choice(
          seq($.struct_field_scope, optional(terminator)),
          seq($.struct_field_declaration, optional(terminator)),
          seq($.interface_method_definition, optional(terminator)),
        ),
      ),
      '}',
    ),

    interface_method_definition: ($) => prec.right(seq(
      field('name', $.identifier),
      field('generic_parameters', optional($.generic_parameters)),
      field('signature', $.signature),
      field('attributes', optional($.attribute)),
    )),

    // ==================== EXPRESSIONS ====================

    _expression: ($) => choice(
      $._expression_without_blocks,
      $._expression_with_blocks,
    ),

    _expression_without_blocks: ($) => choice(
      $.parenthesized_expression,
      $.go_expression,
      $.spawn_expression,
      $.call_expression,
      $.function_literal,
      $.empty_literal_value,
      $.binded_identifier,
      $.reference_expression,
      $._max_group,
      $.map_init_expression,
      $.array_creation,
      $.empty_array_creation,
      $.fixed_array_creation,
      $.unary_expression,
      $.binary_expression,
      $.is_expression,
      $.not_is_expression,
      $.index_expression,
      $.slice_expression,
      // $.type_cast_expression,
      $.as_type_cast_expression,
      $.selector_expression,
      $.enum_fetch,
    ),

    _expression_with_blocks: ($) => choice(
      $.type_initializer,
      $.if_expression,
      $.match_expression,
      $.select_expression,
      $.sql_expression,
      $.lock_expression,
      $.unsafe_expression,
      $.compile_time_if_expression,
    ),

    go_expression: ($) => prec.left(PREC.composite_literal, seq('go', $._expression)),

    spawn_expression: ($) => prec.left(PREC.composite_literal, seq('spawn', $._expression)),

    parenthesized_expression: ($) => seq('(', $._expression, ')'),

    call_expression: ($) => prec.right(PREC.primary, choice(
      seq(
        field('function', token.immediate('json.decode')),
        field('arguments', $.special_argument_list),
        optional($.error_propagate),
      ),
      seq(
        field('name', $._expression),
        field('type_parameters', optional($.type_parameters)),
        field('arguments', $.argument_list),
        optional($.error_propagate),
      ),
    )),

    type_parameters: ($) => prec(PREC.resolve, seq(
      '[',
      comma_sep1($.plain_type),
      ']',
    )),

    argument_list: ($) => seq(
      '(',
      optional(seq(
        choice($.argument),
        repeat(seq(list_separator, choice($.argument))),
        optional(list_separator),
      )),
      ')',
    ),

    argument: ($) => choice(
      $._expression,
      $.mutable_expression,
      $.keyed_element,
      $.spread_expression,
    ),

    special_argument_list: ($) => seq(
      '(',
      choice($.plain_type, $.option_type),
      optional(seq(',', $._expression)),
      ')',
    ),


    type_initializer: ($) => prec.right(PREC.type_initializer, seq(
      field('type', $.plain_type),
      field('body', $.type_initializer_body),
    )),

    type_initializer_body: ($) => seq(
      '{',
      optional(
        choice(
          field('element_list', $.element_list),
          // For short struct init syntax
          field('short_element_list', $.short_element_list),
        ),
      ),
      '}',
    ),

    element_list: ($) => repeat1(seq(
      choice($.spread_expression, $.keyed_element),
      optional(list_separator),
    )),

    short_element_list: ($) => repeat1(seq($.element, optional(list_separator))),

    element: ($) => $._expression,

    keyed_element: ($) => seq(
      field('key', $.field_name),
      ':',
      field('value', $._expression),
    ),

    field_name: ($) => $.reference_expression,

    function_literal: ($) => prec.right(seq(
      'fn',
      field('capture_list', optional($.capture_list)),
      field('generic_parameters', optional($.generic_parameters)),
      field('signature', $.signature),
      field('body', $.block),
    )),

    capture_list: ($) => seq('[', comma_sep($.capture), optional(','), ']'),

    capture: ($) => seq(optional($.mutability_modifiers), $.reference_expression),

    reference_expression: ($) => prec(PREC.primary, $.identifier),
    type_reference_expression: ($) => prec(PREC.primary, $.identifier),

    unary_expression: ($) => prec(PREC.unary, seq(
      field('operator', choice(...unary_operators)),
      field('operand', $._expression),
    )),

    binary_expression: ($) => {
      const table = [
        [PREC.multiplicative, choice(...multiplicative_operators)],
        [PREC.additive, choice(...additive_operators)],
        [PREC.comparative, choice(...comparative_operators)],
        [PREC.and, '&&'],
        [PREC.or, '||'],
      ];

      return choice(...table.map(([precedence, operator]) =>
        prec.left(precedence, seq(
          field('left', $._expression),
          field('operator', operator),
          field('right', $._expression),
        )),
      ));
    },

    as_type_cast_expression: ($) =>
      seq($._expression, 'as', $.plain_type),

    type_cast_expression: ($) => seq(
      field('type', $.plain_type),
      '(',
      field('operand', $._expression),
      ')',
    ),

    compile_time_identifier: ($) => comp_time($.identifier),

    compile_time_selector_expression: ($) =>
      comp_time(seq('(', $.selector_expression, ')')),

    error_propagate: ($) => prec.right(choice('?', '!', $.or_block)),

    or_block: ($) => seq('or', $.block),

    _max_group: ($) => prec.left(PREC.resolve, choice(
      $.pseudo_compile_time_identifier,
      $.literal,
    )),

    escape_sequence: () => token(prec(1, seq(
      '\\',
      choice(
        /u[a-fA-F\d]{4}/,
        /U[a-fA-F\d]{8}/,
        /x[a-fA-F\d]{2}/,
        /\d{3}/,
        /\r?\n/,
        /['"abfrntv$\\]/,
        /\S/,
      ),
    ))),

    literal: ($) => choice(
      $.int_literal,
      $.float_literal,
      $._string_literal,
      $.rune_literal,
      $.none,
      $.true,
      $.false,
      $.nil,
    ),

    none: () => 'none',
    true: () => 'true',
    false: () => 'false',
    nil: () => 'nil',

    spread_expression: ($) => prec.right(PREC.unary, seq(
      '...',
      $._expression,
    )),

    map_init_expression: ($) => prec(PREC.composite_literal, seq(
      '{',
      repeat1(seq($.map_keyed_element, optional(list_separator))),
      '}',
    )),

    map_keyed_element: ($) => seq(
      field('key', $._expression),
      ':',
      field('value', $._expression),
    ),

    array_creation: ($) => prec.right(PREC.multiplicative, $._non_empty_array),

    empty_array_creation: () => prec(PREC.composite_literal, seq('[', ']')),

    fixed_array_creation: ($) => prec.right(PREC.multiplicative,
      seq($._non_empty_array, '!'),
    ),

    _non_empty_array: ($) =>
      seq('[', repeat1(seq($._expression, optional(','))), ']'),

    selector_expression: ($) => prec(PREC.primary, seq(
      field('operand', choice(
        $._expression,
        $.compile_time_identifier,
      )),
      '.',
      field(
        'field',
        choice(
          $.reference_expression,
          $.compile_time_identifier,
          $.compile_time_selector_expression,
        ),
      ))),

    index_expression: ($) => prec.right(PREC.primary, seq(
      field('operand', $._expression),
      '[',
      field('index', $._expression),
      ']',
      optional($.error_propagate),
    )),

    slice_expression: ($) => prec(PREC.primary,
      seq(field('operand', $._expression), '[', $.range, ']'),
    ),

    if_expression: ($) => seq(
      'if',
      choice(
        field('condition', $._expression),
        field('guard', $.var_declaration),
      ),
      field('block', $.block),
      optional(
        seq(
          'else',
          field('else_branch', choice($.block, $.if_expression)),
        ),
      ),
    ),

    compile_time_if_expression: ($) => seq(
      '$if',
      field(
        'condition',
        seq($._expression, optional('?')),
      ),
      field('block', $.block),
      optional(
        seq(
          '$else',
          field('else_branch', choice($.block, $.compile_time_if_expression)),
        ),
      ),
    ),

    is_expression: ($) => prec.left(PREC.comparative, seq(
      field('left', $._expression),
      'is',
      field('right', choice($.option_type, $.plain_type)),
    )),

    not_is_expression: ($) => prec.left(PREC.comparative, seq(
      field('left', $._expression),
      '!is',
      field('right', choice($.option_type, $.plain_type)),
    )),

    enum_fetch: ($) => seq('.', $.identifier),

    match_expression: ($) => seq(
      'match',
      field('condition', choice($._expression, $.mutable_expression)),
      '{',
      optional($.match_arms),
      '}',
    ),

    match_arms: ($) => repeat1(choice($.match_arm, $.match_else_arm_clause)),

    match_arm: ($) => seq(
      field('value', $.match_expression_list),
      field('block', $.block),
    ),

    match_expression_list: ($) =>
      comma_sep1(
        choice(
          $._expression,
          $.match_arm_type,
          alias($._definite_range, $.range),
        ),
      ),

    match_arm_type: ($) => prec(PREC.match_arm_type, $.plain_type),

    match_else_arm_clause: ($) => seq('else', field('block', $.block)),

    select_expression: ($) => seq(
      'select',
      field('selected_variables', optional($.expression_list)),
      '{',
      repeat($.select_arm),
      optional($.select_else_arn_clause),
      '}',
    ),

    select_arm: ($) => seq($.select_arm_statement, $.block),

    select_arm_statement: ($) => prec.left(choice(
      alias($.select_var_declaration, $.var_declaration),
      $.send_statement,
      seq(
        alias($.expression_without_blocks_list, $.expression_list),
        optional($._select_arm_assignment_statement),
      ),
    )),

    _select_arm_assignment_statement: ($) => seq(
      choice(...assignment_operators),
      alias($.expression_without_blocks_list, $.expression_list),
    ),

    select_var_declaration: ($) => prec.left(seq(
      field('var_list', $.identifier_list),
      ':=',
      field('expression_list', alias($.expression_without_blocks_list, $.expression_list)),
    )),

    select_else_arn_clause: ($) => seq('else', $.block),

    lock_expression: ($) => seq(
      choice('lock', 'rlock'),
      field('locked_variables', optional($.expression_list)),
      field('body', $.block),
    ),

    unsafe_expression: ($) => seq('unsafe', $.block),

    // TODO: this should be put into a separate grammar to avoid any "noise"
    sql_expression: ($) => prec(PREC.resolve, seq('sql', optional($.identifier), $._content_block)),

    // ==================== LITERALS ====================

    int_literal: () => token(int_literal),

    float_literal: () => token(float_literal),

    rune_literal: () => token(seq(
      '`',
      choice(
        /[^'\\]/,
        '\'',
        '"',
        seq(
          '\\',
          choice(
            '0',
            '`',
            seq('x', hex_digit, hex_digit),
            seq(octal_digit, octal_digit, octal_digit),
            seq('u', hex_digit, hex_digit, hex_digit, hex_digit),
            seq(
              'U',
              hex_digit,
              hex_digit,
              hex_digit,
              hex_digit,
              hex_digit,
              hex_digit,
              hex_digit,
              hex_digit,
            ),
            seq(choice('a', 'b', 'e', 'f', 'n', 'r', 't', 'v', '\\', '\'', '"')),
          ),
        ),
      ),
      '`',
    )),

    _string_literal: ($) => choice(
      $.c_string_literal,
      $.raw_string_literal,
      $.interpreted_string_literal,
    ),

    c_string_literal: ($) => interpolated_quoted_string($, $._c_string_opening),

    raw_string_literal: ($) => quoted_string($, $._raw_string_opening),

    interpreted_string_literal: ($) => interpolated_quoted_string($, $._string_opening),

    string_interpolation: ($) => seq(
      $._braced_interpolation_opening,
      $._expression,
      optional($.format_specifier),
      $._interpolation_closing,
    ),

    format_specifier: ($) => seq(
      token(':'),
      choice(
        format_flag,
        seq(
          optional(token(/[+\-0]/)),
          optional($.int_literal),
          optional(seq('.', $.int_literal)),
          optional(format_flag),
        ),
      ),
    ),

    pseudo_compile_time_identifier: ($) =>
      seq('@', alias(/[A-Z][A-Z0-9_]+/, $.identifier)),

    identifier: () =>
      token(
        seq(
          optional('@'),
          choice(unicode_letter, '_'),
          repeat(choice(letter, unicode_digit)),
        ),
      ),

    visibility_modifiers: () => prec.left(choice(
      'pub',
      '__global',
    )),

    mutability_modifiers: () => prec.left(choice(
      seq('mut', optional('static')),
      'shared',
    )),

    mutable_identifier: ($) => prec(PREC.resolve, seq(
      $.mutability_modifiers,
      $.identifier,
    )),

    mutable_expression: ($) => prec(PREC.resolve, seq(
      $.mutability_modifiers,
      $._expression,
    )),

    binded_identifier: ($) => seq(
      field('language', choice('C', 'JS')),
      token.immediate('.'),
      field('name', $.identifier),
    ),

    identifier_list: ($) =>
      prec(PREC.and, comma_sep1(choice($.mutable_identifier, $.identifier))),

    expression_list: ($) =>
      prec(PREC.resolve, comma_sep1(choice($._expression, $.mutable_expression))),

    expression_without_blocks_list: ($) =>
      prec(PREC.resolve, comma_sep1($._expression_without_blocks)),

    // TODO: any expression on the right that is recognized
    // as external tokens will be deduced as separate nodes
    // instead of having under the same expression_list node
    _expression_list_repeat1: ($) => seq(
      choice(
        $._expression,
        $.mutable_expression,
      ),
      repeat1(
        seq(
          ',',
          choice(
            $._expression,
            $.mutable_expression,
          ),
        ),
      ),
    ),

    empty_literal_value: () => prec(PREC.composite_literal, seq('{', '}')),

    // ==================== TYPES ====================

    _type: ($) => choice($.plain_type, $.option_type, $.result_type, $.multi_return_type),

    option_type: ($) => prec.right(
      seq('?', optional($._type)),
    ),

    result_type: ($) => prec.right(
      seq('!', optional($._type)),
    ),

    multi_return_type: ($) => seq('(', comma_sep1($._type), optional(','), ')'),

    plain_type: ($) => prec.right(PREC.primary, choice(
      $.type_reference_expression,
      $._binded_type,
      $.qualified_type,
      $.pointer_type,
      $.array_type,
      $.fixed_array_type,
      $.function_type,
      $.generic_type,
      $.map_type,
      $.channel_type,
      $.shared_type,
      $.thread_type,
      $.none_type,
    )),

    fixed_array_type: ($) => seq(
      '[',
      field('size', choice($.int_literal, $.identifier)),
      ']',
      field('element', $.plain_type),
    ),

    array_type: ($) => prec(PREC.resolve,
      seq('[', ']', field('element', $.plain_type)),
    ),

    variadic_type: ($) => seq('...', $.plain_type),

    pointer_type: ($) => prec(PREC.match_arm_type, seq('&', $.plain_type)),

    map_type: ($) =>
      seq('map[', field('key', $.plain_type), ']', field('value', $._type)),

    channel_type: ($) => prec.right(PREC.primary,
      seq('chan', $.plain_type),
    ),

    shared_type: ($) => seq('shared', $.plain_type),

    thread_type: ($) => seq('thread', $.plain_type),

    none_type: () => 'none',

    _binded_type: ($) => prec.right(alias($.binded_identifier, $.binded_type)),

    generic_type: ($) =>
      seq(choice($.qualified_type, $.type_reference_expression), $.type_parameters),

    qualified_type: ($) =>
      seq(
        field('module', $.identifier),
        '.',
        field('name', $.type_reference_expression),
      ),

    function_type: ($) => prec.right(seq(
      'fn',
      field(
        'signature',
        $.signature,
      ),
    )),

    // ==================== TYPES END ====================

    // ==================== STATEMENTS ====================

    _statement_list: ($) => repeat1(seq($._statement, optional($._automatic_separator))),

    _statement: ($) => choice(
      $.simple_statement,
      $.assert_statement,
      $.continue_statement,
      $.break_statement,
      $.return_statement,
      $.asm_statement,
      $.goto_statement,
      $.labeled_statement,
      $.defer_statement,
      $.for_statement,
      $.compile_time_for_statement,
      $.send_statement,
      $.block,
      $.hash_statement,
    ),

    simple_statement: ($) => choice(
      $.var_declaration,
      $._expression,
      $.inc_statement,
      $.dec_statement,
      $.assignment_statement,
    ),

    inc_statement: ($) => seq($._expression, '++'),

    dec_statement: ($) => seq($._expression, '--'),

    assert_statement: ($) => seq('assert', $._expression),

    send_statement: ($) => prec(PREC.unary, seq(
      field('channel', $._expression),
      '<-',
      field('value', $._expression),
    )),

    var_declaration: ($) => prec.right(seq(
      field('var_list', $.expression_list),
      ':=',
      field('expression_list', $.expression_list),
    )),

    _var_definition_list: ($) => comma_sep1($.var_definition),

    var_definition: ($) => prec(PREC.type_initializer, seq(
      field('modifiers', optional('mut')),
      field('name', $.identifier),
    )),

    assignment_statement: ($) => seq(
      field('left', $.expression_list),
      field('operator', choice(...assignment_operators)),
      field('right', $.expression_list),
    ),

    block: ($) => seq(
      '{',
      optional(choice(
        $._statement_list,
        alias($._expression_list_repeat1, $.expression_list),
        alias($.empty_labeled_statement, $.labeled_statement),
        seq(
          $._statement_list,
          choice(
            alias($._expression_list_repeat1, $.expression_list),
            alias($.empty_labeled_statement, $.labeled_statement),
          ),
        ),
      )),
      '}',
    ),

    defer_statement: ($) => seq('defer', $.block),

    label_reference: ($) => $.identifier,

    goto_statement: ($) => seq('goto', $.label_reference),

    break_statement: ($) => prec.right(seq('break', optional($.label_reference))),

    continue_statement: ($) => prec.right(seq('continue', optional($.label_reference))),

    return_statement: ($) => prec.right(seq('return', optional(field('expression_list', $.expression_list)))),

    label_definition: ($) => seq($.identifier, ':'),

    labeled_statement: ($) => seq($.label_definition, $._statement),

    empty_labeled_statement: ($) => prec.left($.label_definition),

    compile_time_for_statement: ($) => seq('$for', $.range_clause, field('body', $.block)),

    for_statement: ($) => seq(
      'for',
      optional(choice(
        $.range_clause,
        $.for_clause,
        $._expression,
      )),
      field('body', $.block),
    ),

    range_clause: ($) => prec.left(PREC.primary, seq(
      field('left', $._var_definition_list),
      'in',
      field(
        'right',
        choice(
          alias($._definite_range, $.range),
          $._expression,
        ),
      ),
    )),

    for_clause: ($) => prec.left(seq(
      field('initializer', optional($.simple_statement)),
      ';',
      field('condition', optional($._expression)),
      ';',
      field('update', optional($.simple_statement)),
    )),

    _definite_range: ($) => prec(PREC.multiplicative, seq(
      field('start', $._expression),
      choice('..', '...'),
      field('end', $._expression),
    )),

    range: ($) => prec(PREC.multiplicative, seq(
      field('start', optional($._expression)),
      '..',
      field('end', optional($._expression)),
    )),

    hash_statement: () => seq('#', token.immediate(repeat1(/.|\\\r?\n/)), terminator),

    asm_statement: ($) => seq('asm', $.identifier, $._content_block),

    // Loose checking for asm and sql statements
    _content_block: () => seq('{', token.immediate(prec(1, /[^{}]+/)), '}'),

    // ==================== ATTRIBUTES ====================

    attributes: ($) => repeat1(seq($.attribute, optional(terminator))),

    attribute: ($) => seq('[', seq($.attribute_expression, repeat(seq(';', $.attribute_expression))), ']'),

    attribute_expression: ($) => prec(PREC.attributes, choice(
      $.if_attribute,
      $._plain_attribute,
    )),

    // [if some ?]
    if_attribute: ($) => seq('if', $.reference_expression, optional('?')),

    _plain_attribute: ($) => choice(
      $.literal_attribute,
      $.value_attribute,
      $.key_value_attribute,
    ),

    // ['/query']
    literal_attribute: ($) => prec(PREC.attributes, $.literal),

    value_attribute: ($) => prec(PREC.attributes,
      field('name', choice(alias('unsafe', $.reference_expression), $.reference_expression)),
    ),

    // [key]
    // [key: value]
    key_value_attribute: ($) => prec(PREC.attributes, seq(
      $.value_attribute,
      ':',
      field('value', choice($.literal, $.identifier)),
    )),
  },
});

function comp_time(rule) {
  return seq('$', rule);
}

function comma_sep1(rules) {
  return seq(rules, repeat(seq(',', rules)));
}

function comma_or_semi_sep1(rules) {
  return seq(rules, repeat(seq(choice(',', terminator), rules)));
}

function comma_sep(rule) {
  return optional(comma_sep1(rule));
}

function interpolated_quoted_string($, opening) {
  return quoted_string($,
    opening,
    $.escape_sequence,
    $.string_interpolation,
    token.immediate('$'),
  )
}

function quoted_string($, opening, ...rules) {
  return seq(
    prec(1, opening),
    repeat(
      choice(
        prec(1, $._string_content),
        ...rules,
      ),
    ),
    $._string_closing,
  );
}
