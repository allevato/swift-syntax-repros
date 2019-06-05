import Foundation
import SwiftSyntax

class RuleBase: SyntaxVisitor {}

final class BrokenVisitor: RuleBase {
  func visit(_ node: TokenSyntax) -> SyntaxVisitorContinueKind {
    print(node.text, terminator: " ")
    return .skipChildren
  }
}

final class WorkingVisitor: SyntaxVisitor {
  func visit(_ node: TokenSyntax) -> SyntaxVisitorContinueKind {
    print(node.text, terminator: " ")
    return .skipChildren
  }
}

let tree = try SyntaxParser.parse(URL(fileURLWithPath: #file))

print("This will print something:")
print("----")
var workingVisitor = WorkingVisitor()
tree.walk(&workingVisitor)
print("----")
print()

// When a base class is introduced between the `SyntaxVisitor` protocol and the
// concrete implementation, none of the `visit` methods ever get called; the
// protocol default implementation does.
print("This will print nothing:")
print("----")
var brokenVisitor = BrokenVisitor()
tree.walk(&brokenVisitor)
print("----")


// ----
// We can see the odd dispatch behavior above with a simpler example:

protocol P {
  func nonmutatingF()
  mutating func mutatingF()
}

extension P {
  func nonmutatingF() { print("P.nonmutatingF") }
  mutating func mutatingF() { print("P.mutatingF") }
}

class Base: P {}

class Concrete: Base {
  func nonmutatingF() { print("C.nonmutatingF") }
  func mutatingF() { print("C.mutatingF") }
}

// This works like we'd expect.
let c = Concrete()
c.mutatingF()
c.nonmutatingF()

// Why does this call the default implementations? These methods are protocol
// requirements; they should be getting dynamically dispatched, right?
var p: P = c
p.mutatingF()
p.nonmutatingF()
