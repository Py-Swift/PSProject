//
//  Array.swift
//  PSTools
//
//  Created by CodeBuilder on 14/11/2025.
//


extension Array {
    //@MainActor
    @inlinable public func asyncMap<T, E>(_ transform: (Element) async throws(E) -> T) async throws(E) -> [T] where E : Error {
        var elements = [T]()
        for element in self {
            elements.append(try await transform(element))
        }
        return elements
    }
}