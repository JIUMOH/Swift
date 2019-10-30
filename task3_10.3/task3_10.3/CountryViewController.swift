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
    
    override func didMove(toParent parent: UIViewController?) {
        
    }
    
    func getDataFromJSON(jsonURL : String, dataName : String){
        guard let url = URL(string: jsonURL) else { return }
        
        let font = UIFont.systemFont(ofSize: 20)
        let attributes = [NSAttributedString.Key.font: font]
        
        URLSession.shared.dataTask(with: url) { (data,respoder,error) in
    
            guard let data = data else { return }
            guard error == nil else { return }
        
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String : String] {
                    if let value = json[self.country!.code] {
                        DispatchQueue.main.async {
                            switch dataName {
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
            } catch let error {
            
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
        
        self.present(optionMenu, animated: true, completion: nil)
        
    }
    
}
