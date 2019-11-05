//
//  TableViewController.swift
//  task3_10.3
//
//  Created by Smikun Denis on 29.10.2019.
//  Copyright © 2019 Smikun Denis. All rights reserved.
//

import UIKit

struct Country {
    var name : String
    var id : String
    var code : String
}

class TableCellView : UITableViewCell {
    @IBOutlet weak var flagImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        flagImage.image = nil
    }
    
}

class TableViewController: UITableViewController {

    var countries : [Country] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for code in NSLocale.isoCountryCodes  {
            let id = NSLocale.localeIdentifier(fromComponents: [NSLocale.Key.countryCode.rawValue: code])
            let name = NSLocale(localeIdentifier: "en_UK") .displayName(forKey: NSLocale.Key.identifier, value: id) ?? "Country not found for code: \(code)"
            let tempCountry = Country(name: name, id: id,code: code)
            countries.append(tempCountry)
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countries.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath) as! TableCellView
        
        cell.flagImage.setImageFromUrl(imageURL: "https://www.countryflags.io/\(countries[indexPath.row].code)/flat/64.png")
        cell.nameLabel.text = countries[indexPath.row].name
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Список стран"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let CountryViewController = segue.destination as? CountryViewController,
            let index = tableView.indexPathForSelectedRow?.row
            else {
                return
        }
        CountryViewController.country = countries[index]
    }
    
    
    func showErrorMessage(){
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: "Error", message: "Coudn’t connect to server!", preferredStyle: .alert)
            
            let retryAction = UIAlertAction(title: "Retry", style: .default) { (action) in
                self.tableView.reloadData()
            }
            let cancelAction = UIAlertAction(title: "OK", style: .cancel) { (action) in
            }
                
            alertController.addAction(retryAction)
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

extension UIImageView {
    
    func setImageFromUrl(imageURL: String) {
        URLSession.shared.dataTask( with: NSURL(string:imageURL)! as URL, completionHandler: {
            (data, response, error) -> Void in
            if error == nil{
                DispatchQueue.main.async {
                    if let data = data {
                        self.image = UIImage(data: data)
                    }
                }
            } else {
                let viewController = UIApplication.getPresentedViewController()
                if viewController!.children.count == 2 { return }
                for item in (viewController!.children){
                    if item is TableViewController{
                        let vC = item as! TableViewController
                        vC.showErrorMessage()
                    }
                }
            }
        }).resume()
    }
}


