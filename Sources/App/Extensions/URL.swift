import Foundation
import FluentProvider
import Vapor

extension URL: NodeConvertible {
    public init(node: Node) throws {
        guard let str = node.string, let url = URL(string: str) else {
            throw NodeError.unableToConvert(input: node, expectation: "", path: [])
        }
        self = url
    }

    public func makeNode(in context: Context?) throws -> Node {
        return Node.string(self.absoluteString, in: context)
    }
}
