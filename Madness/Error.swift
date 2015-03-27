//  Copyright (c) 2015 Rob Rix. All rights reserved.

/// A composite error.
public struct Error<I: ForwardIndexType>: Printable {
	/// Constructs a leaf error, e.g. for terminal parsers.
	public static func leaf(reason: String, _ index: I) -> Error {
		return Error(reason: reason, _index: Box(index), children: [])
	}

	public static func withReason(reason: String, _ index: I) -> (Error, Error) -> Error {
		return { Error(reason: reason, _index: Box(index), children: [$0, $1]) }
	}


	public let reason: String

	public var index: I {
		return _index.value
	}
	private let _index: Box<I>

	public let children: [Error]



	// MARK: Printable

	public var description: String {
		return describe(0)
	}

	private func describe(n: Int) -> String {
		let description = String(count: n, repeatedValue: "\t" as Character) + "\(index): \(reason)"
		if children.count > 0 {
			return description + "\n" + "\n".join(lazy(children).map { $0.describe(n + 1) })
		}
		return description
	}
}


// MARK: - Imports

import Box
import Prelude
