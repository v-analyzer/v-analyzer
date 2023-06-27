module types

const (
	simple       = 1
	string_array = ['hello', 'world']
)

fn main() {
	expr_type(types.simple, 'int')
	expr_type(types.string_array, '[]string')
}
