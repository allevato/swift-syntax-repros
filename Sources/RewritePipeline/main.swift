import Foundation
import SwiftSyntax

class Rewriter1: SyntaxRewriter {
  override func visit(_ node: IntegerLiteralExprSyntax) -> ExprSyntax {
    // Multiply all integer literals by 2.
    let value = Int(node.digits.text)!

    // This doesn't work; creating a node with SyntaxFactory creates an orphaned
    // node, so the next rewriter in the pipeline can't access the previous/next
    // tokens.
    // ---
    return SyntaxFactory.makeIntegerLiteralExpr(
      digits: SyntaxFactory.makeIntegerLiteral("\(value * 2)")
    )

    // Do this instead (uncomment):
    // ---
    // return node.withDigits(node.digits.withKind(.integerLiteral("\(value * 2)")))

    // However, this won't work if we want to replace the node with a node of a
    // *completely different type*. What are our options here? It seems like
    // we'd have to visit one level higher than the node we actually want to
    // look at and replace it among the children of that node.
  }
}

class Rewriter2: SyntaxRewriter {
  override func visit(_ node: IntegerLiteralExprSyntax) -> ExprSyntax {
    // Add 1 to any integer preceded by a minus sign.
    guard
      let previousTokenText = node.previousToken?.text, previousTokenText == "-"
    else {
      return node
    }
    let value = Int(node.digits.text)!
    return node.withDigits(node.digits.withKind(.integerLiteral("\(value + 1)")))
  }
}

class Pipeline: SyntaxRewriter {
  override func visitAny(_ node: Syntax) -> Syntax? {
    guard let integer = node as? IntegerLiteralExprSyntax else {
      return nil
    }
    let node1 = Rewriter1().visit(integer)
    let node2 = Rewriter2().visit(node1)
    return node2
  }
}

let tree = try SyntaxParser.parse(
  source: """
  let x = 10 + 100 - 50 + x - 20

  """)
let newTree = Pipeline().visit(tree)
print(newTree.description)

// If this worked correctly, you should see
//
//     let x = 20 + 200 - 101 + x - 41
//
// If it didn't, you'll get something like:
//
//     let x = 20+ 200- 100+ x - 40
