//
//  ViewController.swift
//  task2
//
//  Created by Stanislav on 25/10/2019.
//  Copyright © 2019 Stanislav. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var index = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        generateCircle()
    }

    public func generateCircle(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            var newCircle : CircleView = CircleView(viewController: self)
        
       
            self.view.addSubview(newCircle)
     
            if (self.index != 50) {
                self.index+=1
                self.generateCircle()
        }
            else{
                self.index = 0
                return  
            }
        }
    }
    
}

