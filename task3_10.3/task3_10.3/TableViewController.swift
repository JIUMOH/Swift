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
    var capital : String
    var phoneCode : String
    var currency : String
}

class TableCellView : UITableViewCell {
    @IBOutlet weak var flagImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
}

class TableViewController: UITableViewController {

    var countries : [Country] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for code in NSLocale.isoCountryCodes  {
            let id = NSLocale.localeIdentifier(fromComponents: [NSLocale.Key.countryCode.rawValue: code])
            let name = NSLocale(localeIdentifier: "en_UK") .displayName(forKey: NSLocale.Key.identifier, value: id) ?? "Country not found for code: \(code)"
            let tempCountry = Country(name: name, id: id,code: code, capital: "", phoneCode: "", currency:  "")
            countries.append(tempCountry)
        }
        
        /*getDataFromJSON(jsonURL: "http://country.io/capital.json", dataName: "capital")
        getDataFromJSON(jsonURL: "http://country.io/phone.json", dataName: "phoneCode")
        getDataFromJSON(jsonURL: "http://country.io/currency.json", dataName: "currency")
        */
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countries.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath) as! TableCellView
        
        cell.flagImage?.image = UIImage(named: "flagImage")
        cell.flagImage?.setImageFromUrl(imageURL: "https://www.countryflags.io/\(countries[indexPath.row].code)/flat/64.png")
        cell.nameLabel?.text = countries[indexPath.row].name
        
        
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
    
    /*func getDataFromJSON(jsonURL : String, dataName : String){
        guard let url = URL(string: jsonURL) else { return }
        
        URLSession.shared.dataTask(with: url) { (data,respoder,error) in
    
            guard let data = data else { return }
            guard error == nil else { return }
        
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String : String] {
                    for i in 0...self.countries.count - 1 {
                        if let value = json[self.countries[i].code] {
                            switch dataName {
                            case "capital":
                                self.countries[i].capital = value
                            case "phoneCode":
                                self.countries[i].phoneCode = value
                            case "currency":
                                self.countries[i].currency = value
                            default:
                                return
                            }
                            
                        }
                    }
                }
                
            } catch let error {
            
            }
        
        }.resume()
    }*/
 
}

extension UIImageView {
    func setImageFromUrl(imageURL :String) {
        URLSession.shared.dataTask( with: NSURL(string:imageURL)! as URL, completionHandler: {
            (data, response, error) -> Void in
            DispatchQueue.main.async {
                if let data = data {
                    self.image = UIImage(data: data)

                }
            }
        }).resume()
    }
}


