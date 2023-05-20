module stubs

// ChanInit describes a chan type initializer.
// Example:
// ```
// ch := chan int{}
// buf_chan := chan int{cap: 10}
// ```
pub struct ChanInit {
pub:
	// cap fields describes the size of the buffered channel.
	//
	// The channel size describes the number of elements that can be
	// written to the channel without blocking.
	// If more elements are written to the channel than the buffer size,
	// then the write is blocked until another thread reads the element
	// from the channel and there is free space.
	//
	// If `cap == 0` (default), then the channel is not buffered.
	//
	// **Example**
	// ```
	// ch := chan int{cap: 10} // buffered channel
	// ch <- 1 // no blocking
	// ```
	//
	// **Example**
	// ```
	// ch := chan int{} // unbuffered channel
	// ch <- 1 // block until another thread reads from the channel
	// ```
	cap int
}
