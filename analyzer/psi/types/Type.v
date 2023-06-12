module types

pub interface Type {
	name() string
	qualified_name() string
	readable_name() string
	module_name() string
	accept(mut visitor TypeVisitor)
}
