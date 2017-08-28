//: DispatchSemaphore example

/// A DispatchSemaphore allows your code to synchronously wait for an asynchronous task to complete
///
/// The usage pattern is:
///		1. create a DispatchSemaphore
///		2. start an asynchronous task
///			a. when complete, tell the DispatchSemaphore
///		3. wait for the DispatchSemaphore

import UIKit
import PlaygroundSupport

/// tell playground to keep running, so our async tasks can finish
PlaygroundPage.current.needsIndefiniteExecution = true

/// tell the URLcache to cache nothing, so we force a network load
///	(and silence some playground sandbox errors)
URLCache.shared = URLCache(memoryCapacity: 0, diskCapacity: 0, diskPath: nil)


func fetchSomethingSynchronously() -> String {
	print("inside fetchSomethingSynchronously")
	
	///		1. create a DispatchSemaphore
	/// use an initial value of zero.
	///	.wait() will decrement the value, and will wait for it to reach zero before returning
	/// .signal() will increment the value, which will let the .wait() call pass
	let semaphore = DispatchSemaphore(value:0)
	
	///		2. start an asynchronous task
	let url = URL(string: "https://nytimes.com")!
	let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
		print("  got data")
		///			a. when complete, tell the DispatchSemaphore
		semaphore.signal()
	}
	task.resume()
	
	///		3. wait for the DispatchSemaphore
	semaphore.wait()
	
	return "ok, got it"
}

let result = fetchSomethingSynchronously()
print("fetchSomethingSynchronously said: \"\(result)\"")


