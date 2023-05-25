module types

struct FooBar {
}

fn foo() string {}

fn foo_int() int {}

fn get_foo_bar() FooBar {}

fn main() {
	expr_type(foo(), 'string')
	expr_type(foo_int(), 'int')
	expr_type(get_foo_bar(), 'FooBar')
}
