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
module lang

import analyzer.psi
import analyzer.psi.types

pub fn get_zero_value_for(typ types.Type) string {
	return match typ {
		types.PrimitiveType {
			match typ.name {
				'bool' { 'false' }
				'rune' { '`0`' }
				'char', 'u8' { '0' }
				'voidptr', 'byteptr', 'charptr', 'nil' { 'unsafe { nil }' }
				'f32', 'f64' { '0.0' }
				else { '0' }
			}
		}
		types.StructType {
			match typ.name() {
				'string' { "''" }
				else { typ.readable_name() + '{}' }
			}
		}
		types.ArrayType {
			return '[]'
		}
		types.FixedArrayType {
			return '[]!'
		}
		types.MapType {
			return '{}'
		}
		types.ChannelType {
			return 'chan ${typ.inner.readable_name()}{}'
		}
		types.FunctionType {
			return '${typ.readable_name()} {}'
		}
		types.AliasType {
			return get_zero_value_for(typ.inner)
		}
		types.GenericInstantiationType {
			return get_zero_value_for(typ.inner)
		}
		types.InterfaceType, types.PointerType {
			return 'unsafe { nil }'
		}
		types.OptionType {
			return 'none'
		}
		types.ResultType {
			if !typ.no_inner {
				return get_zero_value_for(typ.inner)
			}

			return "error('')"
		}
		else {
			return '0'
		}
	}
}

pub fn is_same_module(context psi.PsiElement, element psi.PsiElement) bool {
	context_module_fqn := context.containing_file.module_fqn()
	element_module_fqn := element.containing_file.module_fqn()
	return context_module_fqn == element_module_fqn
}
