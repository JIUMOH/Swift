//
//  ViewController.swift
//  task3_10.3
//
//  Created by Smikun Denis on 29.10.2019.
//  Copyright © 2019 Smikun Denis. All rights reserved.
//

import UIKit

class CountryViewController: UIViewController {

    @IBOutlet weak var countryImage: UIImageView!
    @IBOutlet weak var countryName: UILabel! 
    @IBOutlet weak var countryCapital: UILabel!
    @IBOutlet weak var countryPhoneCode: UILabel!
    @IBOutlet weak var countryCurrency: UILabel!
    
    var country: Country?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Wiki", style: .plain, target: self, action: #selector(navigationBarButtonTap))
        
        let queue = DispatchQueue.global(qos : .utility)
        queue.async {
            self.getDataFromJSON(jsonURL: "http://country.io/capital.json", dataName: "capital")
            self.getDataFromJSON(jsonURL: "http://country.io/phone.json", dataName: "phoneCode")
            self.getDataFromJSON(jsonURL: "http://country.io/currency.json", dataName: "currency")
        }
    }
    
    func getDataFromJSON(jsonURL : String, dataName : String){
        guard let url = URL(string: jsonURL) else { return }
        
        let font = UIFont.systemFont(ofSize: 20)
        let attributes = [NSAttributedString.Key.font: font]
        
        var tempDataName = dataName
        
        URLSession.shared.dataTask(with: url) { (data,respoder,error) in
    
            guard let data = data else {
                if dataName.contains("retry") {
                    self.showErrorMessage()
                } else {
                    self.getDataFromJSON(jsonURL: jsonURL, dataName: "retry" + dataName)
                }
                return
            }
            guard error == nil else {
                if dataName.contains("retry") {
                    self.showErrorMessage()
                } else {
                    self.getDataFromJSON(jsonURL: jsonURL, dataName: "retry" + dataName)
                }
                return
            }
        
            if dataName.contains("retry") {
                tempDataName = String(dataName.dropFirst(5))
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String : String] {
                    if let value = json[self.country!.code] {
                        DispatchQueue.main.async {
                            switch tempDataName {
                                case "capital":
                                    self.countryImage?.setImageFromUrl(imageURL: "https://www.countryflags.io/\(self.country!.code)/shiny/64.png")
                                    self.countryName?.attributedText = NSAttributedString(string: self.country!.name, attributes: attributes)
                                    self.countryCapital?.attributedText = NSAttributedString(string: value, attributes: attributes)
                                case "phoneCode":
                                    if !value.contains("+") && value.count != 0 { self.countryPhoneCode?.attributedText = NSAttributedString(string: "+" + value, attributes: attributes) }
                                    else { self.countryPhoneCode?.attributedText = NSAttributedString(string: value, attributes: attributes) }
                                case "currency":
                                    self.countryCurrency?.attributedText = NSAttributedString(string:  value, attributes: attributes)
                                default:
                                    return
                            }
                        }
                    }
                }
            } catch {
                    self.showErrorMessage()
            }
        
        }.resume()
    }
    
    @objc func navigationBarButtonTap(){
        let optionMenu = UIAlertController(title: nil, message: "Choose option", preferredStyle: .actionSheet)
        let appAction = UIAlertAction(title: "App", style: .default ){ (action) in
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let webViewController = storyBoard.instantiateViewController(withIdentifier: "webView") as! WebViewController
            webViewController.url = "https://wikipedia.org/wiki/" + self.country!.name
            self.navigationController?.pushViewController(webViewController, animated: true)
        }
        let safariAction = UIAlertAction(title: "Safari", style: .default ){ (action) in
            guard let url = URL(string: "https://wikipedia.org/wiki/" + self.country!.name) else { return }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        optionMenu.addAction(appAction)
        optionMenu.addAction(safariAction)
        
       
        if let popoverController = optionMenu.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
            
        self.present(optionMenu, animated: true, completion: nil)
        
    }
    
    func showErrorMessage(){
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: "Error", message: "Coudn’t connect to server!", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "OK", style: .cancel) { (action) in
            }
            alertController.addAction(cancelAction)
            
            if let popoverController = alertController.popoverPresentationController {
                popoverController.sourceView = self.view
                popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
            }
            
            self.present(alertController, animated: true)
        }
    }
    
}
