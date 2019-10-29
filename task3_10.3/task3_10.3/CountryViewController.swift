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
    
    
    var country: Country?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //countryImage?.image = UIImage()
        countryImage?.setImageFromUrl(ImageURL: "https://www.countryflags.io/\(country!.code)/shiny/64.png")
        countryName?.text  = country?.name
        
        // Do any additional setup after loading the view.
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
