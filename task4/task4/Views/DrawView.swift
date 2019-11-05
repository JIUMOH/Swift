//
//  DrawView.swift
//  task4
//
//  Created by Stanislav on 01.11.2019.
//  Copyright © 2019 Stanislav. All rights reserved.
//

import UIKit

class DrawView: UIView {

    var strokeColor = UIColor.red.cgColor
    
    var line : [CGPoint] = [CGPoint()]
        
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let context = UIGraphicsGetCurrentContext() else  { return }

        context.setStrokeColor(strokeColor)
        
        context.setLineWidth(10)
        context.setLineCap(.butt)
        
        for (i, p) in line.enumerated() {
            if i == 0 {
                context.move(to: p)
            } else {
                context.addLine(to: p)
            }
        }
        
        
        context.strokePath()
        
        
    }

}

