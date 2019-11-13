//
//  ViewController.swift
//  task5
//
//  Created by Stanislav on 11.11.2019.
//  Copyright © 2019 Stanislav. All rights reserved.
//

import UIKit
import CoreData

class FolderViewController: UIViewController {

    var folder : NSManagedObject?
    var delegate: FolderDelegate?
    var viewMode: String?
    var namesList = [String]()
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var managedContext : NSManagedObjectContext {
        return appDelegate.persistentContainer.viewContext
    }
    
    @IBOutlet weak var nameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if viewMode == "Edit" {
            nameTextField.text = folder?.value(forKey: "name") as? String
        }
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneButtonTap))
    
        loadData()
    }
    
    @objc func doneButtonTap() {
        if nameTextField.text!.isEmpty {
//            showErrorMessage(message: "You did not enter a name!")
              navigationController?.popViewController(animated: true)
              return
        }
        if namesList.contains(nameTextField.text!)
            && nameTextField.text != folder?.value(forKey: "name") as? String {
            showErrorMessage(message: "This name is already in use!")
            return
        }
        
        if viewMode == "Edit" {
            delegate?.onNameChanged(name: nameTextField.text!)
        } else {
            delegate?.onNewFolder(name: nameTextField.text!)
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    func loadData(){
        var subFolders = NSSet()
        if viewMode == "Edit" {
            guard let owner = folder?.value(forKey: "owner") as! NSManagedObject? else { return }
            subFolders = owner.value(forKey: "subFolders") as! NSSet
        } else {
            subFolders = folder!.value(forKey: "subFolders") as! NSSet
        }
        namesList.removeAll()
        for f in subFolders {
            if f is NSManagedObject {
                let ff = f as! NSManagedObject
                namesList.append(ff.value(forKey: "name") as! String)
            }
        }
    }
    
    func showErrorMessage(message : String){
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
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

