//
//  ViewController.swift
//  test
//
//  Created by Stanisla on 24/10/2019.
//  Copyright © 2019 Stanisla. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        
        // Do any additional setup after loading the view.
    }
    @IBAction func buttonTap(_ sender: Any) {
        
        let newBox: BoxView = BoxView()
        view.addSubview(newBox)
    }
    
}

