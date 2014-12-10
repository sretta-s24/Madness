//  Copyright (c) 2014 Rob Rix. All rights reserved.

/// Convenience for describing the types of parser combinators.
///
/// \param Tree  The type of parse tree generated by the parser.
public struct Parser<Tree> {
	/// The type of parser combinators.
	public typealias Function = String -> (Tree, String)?
}


// MARK: - Terminals

/// Returns a parser which parses `string`.
public func literal(string: String) -> Parser<String>.Function {
	return {
		startsWith($0, string) ?
			(string, $0.fromOffset(countElements(string)))
		:	nil
	}
}


// MARK: - Nonterminals

/// Parses the concatenation of `left` and `right`, pairing their parse trees.
public func ++ <T, U> (left: Parser<T>.Function, right: Parser<U>.Function) -> Parser<(T, U)>.Function {
	return {
		left($0).map { x, rest in
			right(rest).map { y, rest in
				((x, y), rest)
			}
		} ?? nil
	}
}


/// Parses either `left` or `right`.
public func | <T, U> (left: Parser<T>.Function, right: Parser<U>.Function) -> Parser<Either<T, U>>.Function {
	return {
		left($0).map { (.left($0), $1) } ?? right($0).map { (.right($0), $1) }
	}
}

/// Parses either `left` or `right` and coalesces their trees.
public func | <T> (left: Parser<T>.Function, right: Parser<T>.Function) -> Parser<T>.Function {
	return map(left | right) { $0.either(id, id) }
}


/// Parses `parser` 0 or more times.
public postfix func * <T> (parser: Parser<T>.Function) -> Parser<[T]>.Function {
	return fix { repeat in
		{
			parser($0).map {
				let repeated = repeat($1) ?? ([], $1)
				return ([$0] + repeated.0, repeated.1)
			} ?? ([], $0)
		}
	}
}


/// Parses `parser` 1 or more times.
public postfix func + <T> (parser: Parser<T>.Function) -> Parser<[T]>.Function {
	return map(parser ++ parser*) {
		[$0] + $1
	}
}


/// Returns a parser which maps parse trees into another type.
public func map<T, U>(parser: Parser<T>.Function, f: T -> U) -> Parser<U>.Function {
	return {
		parser($0).map { (f($0), $1) }
	}
}



/// MARK: - Operators

/// Concatenation operator.
infix operator ++ {
	/// Associates to the right, linked-list style.
	associativity right

	/// Higher precedence than |.
	precedence 160
}


/// Zero-or-more repetition operator.
postfix operator * {}


/// One-or-more repetition operator.
postfix operator + {}


// MARK: - Imports

import Either
import Prelude