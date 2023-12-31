// MIT License
//
// Copyright (c) 2023-2024 V Open Source Community Association (VOSCA) vosca.dev
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
module types

pub fn unwrap_pointer_type(typ Type) Type {
	if typ is PointerType {
		return typ.inner
	}
	return typ
}

pub fn unwrap_alias_type(typ Type) Type {
	if typ is AliasType {
		return typ.inner
	}
	return typ
}

pub fn unwrap_channel_type(typ Type) Type {
	if typ is ChannelType {
		return typ.inner
	}
	return typ
}

pub fn unwrap_result_or_option_type(typ Type) Type {
	if typ is ResultType {
		return typ.inner
	}
	if typ is OptionType {
		return typ.inner
	}
	return typ
}

pub fn unwrap_result_or_option_type_if(typ Type, condition bool) Type {
	if condition {
		return unwrap_result_or_option_type(typ)
	}
	return typ
}

pub fn unwrap_generic_instantiation_type(typ Type) Type {
	if typ is GenericInstantiationType {
		return typ.inner
	}
	return typ
}

pub fn is_builtin_array_type(typ Type) bool {
	if typ is StructType {
		return typ.qualified_name() == builtin_array_type.qualified_name()
	}
	return false
}

pub fn is_builtin_map_type(typ Type) bool {
	if typ is StructType {
		return typ.qualified_name() == builtin_map_type.qualified_name()
	}
	return false
}

struct IsGenericVisitor {
mut:
	is_generic bool
}

fn (mut v IsGenericVisitor) enter(typ Type) bool {
	if typ is GenericType {
		v.is_generic = true
		return false
	}
	return true
}

pub fn is_generic(typ Type) bool {
	if typ is GenericType {
		return true
	}

	mut v := IsGenericVisitor{}
	typ.accept(mut v)
	return v.is_generic
}
