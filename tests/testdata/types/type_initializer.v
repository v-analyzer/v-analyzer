module types

struct FooBar {
}

fn main() {
	expr_type(FooBar{}, 'FooBar')
	expr_type(&FooBar{}, '&FooBar')
	expr_type([]int{}, '[]int')
	expr_type([]&FooBar{}, '[]&FooBar')
	expr_type(map[string]int{}, 'map[string]int')
}
