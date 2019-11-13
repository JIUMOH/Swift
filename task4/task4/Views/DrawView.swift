//
//  DrawView.swift
//  task4
//
//  Created by Stanislav on 01.11.2019.
//  Copyright © 2019 Stanislav. All rights reserved.
//

import UIKit

class DrawView: UIView {

    var strokeColor = UIColor.red
    var strokeWidth : CGFloat = 1.0
    
    var line : [CGPoint] = [CGPoint()]
    
    var shapeLayer = CAShapeLayer()
    
    func drawView() {
        setFrame()
        
        let linePath = UIBezierPath()
    
        for (i, p) in line.enumerated() {
            let p1 = CGPoint(x: p.x - frame.minX, y: p.y - frame.minY)
            if i == 0 {
                linePath.move(to: p1)
            } else {
                linePath.addLine(to: p1)
            }
        }
        shapeLayer.path = linePath.cgPath
        shapeLayer.strokeColor = strokeColor.cgColor
        shapeLayer.lineWidth = strokeWidth
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineCap = .round
        self.layer.addSublayer(shapeLayer)
    }
    
    func setFrame(){
        
        var maxX : CGFloat = 0
        var maxY : CGFloat = 0
        var minX : CGFloat = 0
        var minY : CGFloat = 0
        
        for (i, p) in line.enumerated() {
            if i == 0 {
                minX = p.x
                minY = p.y
            } else {
                if maxX < p.x { maxX = p.x }
                if maxY < p.y { maxY = p.y }
                if minX > p.x { minX = p.x }
                if minY > p.y { minY = p.y }
            }
        }
        self.frame = CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }
}

