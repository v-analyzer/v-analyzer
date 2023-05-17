module main

// constant_from_other_file is just a constant
// const constant_from_other_file = 100

// function_in_other_file just a function
fn function_in_other_file() {
	SomeStruct{}.name
}

fn create_some_data() {
}

[attribute]
pub struct Deprecated {
	name            string   = 'deprecated'
	with_arg        bool     = true
	arg_is_optional bool     = true
	target          []Target = [Target.struct_, Target.function, Target.field, Target.constant,
	Target.type_alias]
}
