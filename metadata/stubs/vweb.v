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
module stubs

// This file contains stubs for the vweb module.

import vweb

struct VWebTemplate {}

// html method renders a template.
// See documentation for [$vweb]($vweb) for more information.
pub fn (v VWebTemplate) html() vweb.Result

// $vweb constant allows you to render HTML template in endpoint functions.
//
// `$vweb.html()` in method like `<folder>_<name>() vweb.Result`
// render the `<name>.html` in folder `./templates/<folder>`
//
// `$vweb.html()` compiles an HTML template into V during compilation, and
// embeds the resulting code into the current function.
// That means that the template automatically has access to that
// function's entire environment (like variables).
//
// See [vweb documentation](https://modules.vosca.dev/standard_library/vweb.html) for more information.
//
// Example:
// ```
// ['/']
// pub fn (mut app App) page_home() vweb.Result {
//   // will render `./templates/page/home.html`
//   return $vweb.html()
// }
// ```
pub const $vweb = VWebTemplate{}
