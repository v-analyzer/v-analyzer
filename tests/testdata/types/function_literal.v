module types

fn main() {
	func := fn () {}
	expr_type(func, 'fn ()')

	func2 := fn (i int) {}
	expr_type(func2, 'fn (int)')

	func3 := fn (i int) string {}
	expr_type(func3, 'fn (int) string')
}

fn calls() {
	func := fn (i int) string {}
	expr_type(func(), 'string')

	func1 := fn (i int) int {}
	expr_type(func1(), 'int')
}
