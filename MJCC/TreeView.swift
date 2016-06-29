//
//  TreeView.swift
//  MJCC
//
//  Created by MJsaka on 16/6/17.
//  Copyright © 2016年 MJsaka. All rights reserved.
//

import UIKit

struct NodePosition {
    let left : CGFloat
    let right : CGFloat
    let vertical : CGFloat
}

class TreeView: UIView {
    var root : EquationNode!
    var depth : CGFloat!
    let radius : CGFloat = 20
    let fontSize : CGFloat = 18
    
    override func drawRect(rect: CGRect) {
        if self.depth == nil {
            self.depth = TreeView.depth(root)
        }

        let context : CGContextRef = UIGraphicsGetCurrentContext()!
        CGContextSetRGBStrokeColor(context, 0.8, 0.8, 0.8, 1)
        let pos = NodePosition(left: self.bounds.origin.x, right: self.bounds.width, vertical: self.bounds.size.height / (self.depth * 2) )
        self.draw(root, pos: pos, context: context)
    }
    
    func draw(node : EquationNode , pos : NodePosition , context : CGContextRef){
        let p : CGPoint = CGPoint(x: (pos.left + pos.right) / 2, y: pos.vertical)
        var lpos : NodePosition
        var rpos : NodePosition
        var lcenter : CGPoint
        var rcenter : CGPoint
        
        if let l = node.leftChild {
            if node.rightChild == nil {
                lpos = NodePosition(left: pos.left, right: pos.right, vertical: p.y + self.frame.height / self.depth)
                lcenter = CGPoint(x: (lpos.left + lpos.right)/2, y: lpos.vertical)
            }else {
                lpos = NodePosition(left: pos.left, right: p.x, vertical: p.y + self.frame.height / self.depth)
                lcenter = CGPoint(x: (lpos.left + lpos.right)/2, y: lpos.vertical)
            }
            self.drawLine(context, from: p, to: lcenter)
            self.draw(l, pos: lpos, context: context)
        }
        if let r = node.rightChild {
            if node.leftChild == nil {
                rpos = NodePosition(left: pos.left, right: pos.right, vertical: p.y + self.frame.height / self.depth)
                rcenter = CGPoint(x: (rpos.left + rpos.right)/2, y: rpos.vertical)
            }else {
                rpos = NodePosition(left: p.x, right: pos.right, vertical: p.y + self.frame.height / self.depth)
                rcenter = CGPoint(x: (rpos.left + rpos.right)/2, y: rpos.vertical)
            }
            self.drawLine(context, from: p, to: rcenter)
            self.draw(r, pos: rpos, context: context)
        }
        
        self.drawNode(node, context: context, pos: p)
    }
    
    func drawNode(node : EquationNode , context : CGContextRef , pos : CGPoint) {
        CGContextAddArc(context, pos.x, pos.y, radius, 0, 2 * CGFloat(M_PI), 0)
        CGContextSetLineWidth(context, 2)
        CGContextSetAlpha(context, 1.0)
        CGContextSetStrokeColorWithColor(context, UIColor.grayColor().CGColor)
        CGContextSetFillColorWithColor(context, UIColor.whiteColor().CGColor)
        CGContextDrawPath(context, CGPathDrawingMode.FillStroke)

        let title : NSString = NSString(string: node.name())
        
        let color: UIColor = UIColor.darkGrayColor()
        let font = UIFont(name: "PingFang SC", size: fontSize)
        
        let attributes = [
            NSForegroundColorAttributeName: color,
            NSFontAttributeName: font!
        ]
        title.drawAtPoint(pos, withAttributes: attributes)
    }
    
    func drawLine(context : CGContextRef , from : CGPoint , to : CGPoint)
    {
        CGContextBeginPath(context);
        CGContextMoveToPoint(context, from.x, from.y)
        CGContextAddLineToPoint(context, to.x, to.y)
        
        CGContextSetStrokeColorWithColor(context, UIColor.grayColor().CGColor)
        CGContextSetBlendMode(context, CGBlendMode.Normal)
        CGContextSetLineJoin(context, CGLineJoin.Round)
        CGContextSetLineCap(context , CGLineCap.Round)
        CGContextSetMiterLimit(context, 0.5)
        CGContextSetLineWidth(context, 2)
        CGContextSetAlpha(context, 1.0)
        
        CGContextStrokePath(context)
    }
    
    static func minimumSize(root : EquationNode) -> CGSize {
        let depth = self.depth(root)
        let w = pow(2, depth - 1) * 60
        let h = depth * 60
        return CGSize(width: w, height: h)
    }
    
    static func depth(node : EquationNode) -> CGFloat {
        if node.leftChild == nil && node.rightChild == nil {
            return 1
        }else {
            var dl : CGFloat = 0
            var dr : CGFloat = 0
            if let l = node.leftChild {
                dl = self.depth(l)
            }
            if let r = node.rightChild {
                dr = self.depth(r)
            }
            let d = dl > dr ? dl : dr
            return d+1
        }
    }
}
