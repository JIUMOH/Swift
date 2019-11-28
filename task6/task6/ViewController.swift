//
//  ViewController.swift
//  task6
//
//  Created by Stanislav on 16.11.2019.
//  Copyright © 2019 Stanislav. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    lazy var prevExpression = "0"
    
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var clearButton: UIButton!
    
    lazy var isNewExpression = true
    var currentOperation : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func numberPressed(_ sender: Any) {
        if isNewExpression {
            resultLabel.text = ""
            isNewExpression = false
            if resultLabel.text == "0" {
                clearButton.titleLabel?.text = "C"
            }
        }
        resultLabel.text = resultLabel.text! + String((sender as! UIButton).tag - 1)
    }
    
    @IBAction func operatorPressed(_ sender: Any) {
        let buttonTittle = (sender as! UIButton).titleLabel?.text
        
        var result = ""
        switch buttonTittle {
        case "+":
            result = String(Float(prevExpression)! + Float(resultLabel.text!)!)
        case "-":
            result = String(Float(prevExpression)! - Float(resultLabel.text!)!)
        case "X":
            result = String(Float(prevExpression)! * Float(resultLabel.text!)!)
        case "/":
            result = String(Float(prevExpression)! / Float(resultLabel.text!)!)
        case "=":
            switch currentOperation {
            case "+":
                result = String(Float(prevExpression)! + Float(resultLabel.text!)!)
            case "-":
                result = String(Float(prevExpression)! - Float(resultLabel.text!)!)
            case "X":
                result = String(Float(prevExpression)! * Float(resultLabel.text!)!)
            case "/":
                result = String(Float(prevExpression)! / Float(resultLabel.text!)!)
            default:
                break
            }
            isNewExpression = true
            let temp = result
            if result.popLast() == "0"
                && result.popLast() == "." {
                resultLabel.text = prevExpression
                prevExpression = result
            } else {
                resultLabel.text = temp
                prevExpression = temp
            }
            currentOperation = nil
            return
        default:
            break
        }
        if buttonTittle == "=" {
            currentOperation = nil
        } else {
            currentOperation = buttonTittle
        }
        isNewExpression = true
        let temp = result
        if result.popLast() == "0"
            && result.popLast() == "." {
            
            prevExpression = result
        } else {
            resultLabel.text = temp
            prevExpression = temp
        }
    }
    
    @IBAction func additionalButtonPressed(_ sender: Any) {
        let buttonTittle = (sender as! UIButton).titleLabel?.text
        switch buttonTittle {
        case "C","AC":
            resultLabel.text = "0"
            clearButton.titleLabel?.text = "AC"
            prevExpression = "0"
        case ".":
            if !resultLabel.text!.contains("."){
                resultLabel.text = resultLabel.text! + "."
            }
        case "+/-":
            if resultLabel.text!.contains("."){
                resultLabel.text = String(Float(resultLabel.text!)! * -1)
            } else {
                resultLabel.text = String(Int(resultLabel.text!)! * -1)
            }
        case "%":
            resultLabel.text = String(Float(resultLabel.text!)! / 100)
        default:
            break
        }
    }
    
    
}

extension UIButton{
    override open var isHighlighted: Bool {
        didSet {
            var color = UIColor()
            switch tag {
            case 1...11:
                color = UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: 1.0)
                backgroundColor = isHighlighted ? UIColor.lightGray : color
            case 12...15:
                color = UIColor(red: 169/255, green: 169/255, blue: 169/255, alpha: 1.0)
                backgroundColor = isHighlighted ? color : UIColor.lightText
            case _:
                backgroundColor = isHighlighted ? UIColor(red: 201/255, green: 114/255, blue: 54/255, alpha: 1.0) : UIColor(red: 247/255, green: 147/255, blue: 49/255, alpha: 1.0)
                
            }
        }
    }
}

