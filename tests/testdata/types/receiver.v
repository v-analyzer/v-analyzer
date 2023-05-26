module types

struct ReceiverFoo {}

fn (r &ReceiverFoo) method() {
	expr_type(r, '&ReceiverFoo')
	expr_type(*r, 'ReceiverFoo')
}
