module types

struct FooBar {}

fn foo(param &FooBar, param2 []&FooBar) {
	expr_type(param, '&FooBar')
	expr_type(param2, '[]&FooBar')
}
