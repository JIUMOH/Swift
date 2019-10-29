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
    
}

class TableViewController: UITableViewController {

    var countries : [Country] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for code in NSLocale.isoCountryCodes  {
            let id = NSLocale.localeIdentifier(fromComponents: [NSLocale.Key.countryCode.rawValue: code])
            let name = NSLocale(localeIdentifier: "en_UK").displayName(forKey: NSLocale.Key.identifier, value: id) ?? "Country not found for code: \(code)"
            let tempCountry = Country(name: name, id: id,code: code)
            countries.append(tempCountry)
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countries.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath) as! TableCellView
        
        cell.flagImage?.image = UIImage(named: "flagImage")
        cell.flagImage?.setImageFromUrl(ImageURL: "https://www.countryflags.io/\(countries[indexPath.row].code)/flat/64.png")
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
    
}

extension UIImageView {
    func setImageFromUrl(ImageURL :String) {
        URLSession.shared.dataTask( with: NSURL(string:ImageURL)! as URL, completionHandler: {
            (data, response, error) -> Void in
            DispatchQueue.main.async {
                if let data = data {
                    self.image = UIImage(data: data)

                }
            }
        }).resume()
    }
}


