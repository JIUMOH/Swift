//
//  CircleView.swift
//  task2
//
//  Created by Stanislav on 25/10/2019.
//  Copyright © 2019 Stanislav. All rights reserved.
//

import UIKit

class CircleView: UIView {

    init (viewController: ViewController){
        super.init(frame: CGRect(x : 0, y : 0, width : 0, height: 0))
        self.viewController = viewController
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func didMoveToSuperview() {
        if self.superview == nil {return}
        
        let randomRed: CGFloat = CGFloat.random(in: 0...256)
        let randomGreen: CGFloat = CGFloat.random(in: 0...256)
        let randomBlue: CGFloat = CGFloat.random(in: 0...256)
        let myColor =  UIColor(red: CGFloat(randomRed/255), green: CGFloat(randomGreen/255), blue: CGFloat(randomBlue/255), alpha: 0)
       
        self.backgroundColor = myColor
        
        
        
        let screen = UIScreen.main.bounds
        let width:CGFloat = screen.size.width*CGFloat.random(in: 0.2...1)
        let cWidth = CGFloat.random(in: 0...screen.size.width-width)
        let cHeight = CGFloat.random(in: 0...screen.size.height-width)
        
        
        self.frame = CGRect(x: cWidth , y: cHeight, width: 0, height: 0)
        
        
        UIView.animate(withDuration: 0.5) {
            self.backgroundColor = UIColor(red: CGFloat(randomRed/255), green: CGFloat(randomGreen/255), blue: CGFloat(randomBlue/255), alpha: 1.0)
            self.frame = CGRect(x: cWidth , y: cHeight, width: width, height: width)
        }
        
        
        self.clipsToBounds = true
        self.layer.masksToBounds = true
        self.layer.cornerRadius = width / 2
    
        setupGestureRecognizers()
    }
    		
    private var viewController: ViewController = ViewController()
    
    private let singleTapGestureRecognizer = UITapGestureRecognizer()
}

extension CircleView: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool
    {
        return gestureRecognizer === singleTapGestureRecognizer
    }

}

extension CircleView{
    
    private func setupGestureRecognizers() {
        singleTapGestureRecognizer.addTarget(self, action: #selector(handleSingleTapGesture(_:)))
        singleTapGestureRecognizer.numberOfTapsRequired = 1
    
        singleTapGestureRecognizer.delegate = self

        self.addGestureRecognizer(singleTapGestureRecognizer)
    
    }

    @objc private func handleSingleTapGesture(_ gestureRecognizer: UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.5) {
            self.backgroundColor = self.backgroundColor?.withAlphaComponent(0)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        self.removeFromSuperview()
            if self.viewController.view.subviews.count == 0 {self.viewController.generateCircle()}
        }
    }
    
}
