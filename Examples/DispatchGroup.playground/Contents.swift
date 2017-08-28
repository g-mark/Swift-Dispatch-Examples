//: DispatchGroup example

/// A DispatchGroup allows your code to wait for multiple concurrent, asynchronous tasks
/// to complete.
///
/// The usage pattern is:
///		1. create a DispatchGroup
///		2. register a closure with the DispatchGroup that will get called
///			when all tasks are complete.
///		3. for each task:
///			a. let the DispatchGroup know you are starting a task
///			b. start the task
///			c. when each task completes, let the DispatchGroup know

import UIKit
import PlaygroundSupport

/// tell playground to keep running, so our async tasks can finish
PlaygroundPage.current.needsIndefiniteExecution = true

/// tell the URLcache to cache nothing, so we force a network load
///	(and silence some playground sandbox errors)
URLCache.shared = URLCache(memoryCapacity: 0, diskCapacity: 0, diskPath: nil)


func fetchAllTheThings(_ completion:@escaping () -> (Void)) {
	print("inside fetchAllTheThings")
	
	///		1. create a DispatchGroup
	let group = DispatchGroup()

	/// list of url strings to load
	///		including localhost at the end to show the out-of-order nature of the requests
	///		if you have a local webserver running, this should complete first.
	///		if you don't have one running, then remove it from the list.
	let uris = ["https://nytimes.com", "https://amazon.com", "https://www.washingtonpost.com", "http://localhost"]

	///		3. for each task:
	for uri in uris {
		if let url = URL(string: uri) {
			
			/// start loading one
			print("  loading: \(uri)")
			
			///			a. let the DispatchGroup know you are starting a task
			/// group.enter increments the group execution (or, "in progress") count
			group.enter()
			
			///			b. start the task
			/// start the async task of loading one url
			URLSession.shared.dataTask(with: url) { (data, response, error) in
				print("  got data for \(uri)")
				
				///			c. when each task completes, let the DispatchGroup know
				/// group.leave decrements the group execution count
				group.leave()
			}.resume()
		}
	}

	///		2. register a closure with the DispatchGroup that will get called
	///			when all tasks are complete.

	/// at this point a group.enter() call has been made for each url,
	///	and the group's execution (or, "in progress") count is uris.count

	/// here we wait for the group's execution count to reach zero
	/// eventually, the async URLSession data tasks will complete,
	///	resulting in matched calls to group.leave()
	///		(e.g. 3 calls to .enter(), 3 calls to .leave())
	group.notify(queue: DispatchQueue.main, execute: completion)
}

fetchAllTheThings {
	print("all things have been fetched")
}

