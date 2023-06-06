module types

struct GenericStruct[T] {}

fn main() {
	expr_type(GenericStruct[int]{}, 'types.GenericStruct[int]')
}
