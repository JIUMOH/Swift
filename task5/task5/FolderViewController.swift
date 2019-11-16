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

    var folder : Folder?
    var delegate: TableViewControllerDelegate?
    var viewMode : String?
    
    @IBOutlet weak var nameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        nameTextField.text = folder!.name
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneButtonTap))
    }
    
    @objc func doneButtonTap() {
        if nameTextField.text!.isEmpty {
//            showErrorMessage(message: "You did not enter a name!")
              folder?.delete()
              navigationController?.popViewController(animated: true)
              return
        }
        
        if folder!.owner!.isHasSubFolderWithName(name: nameTextField.text!)
         && nameTextField.text != folder!.name{
            showErrorMessage(message: "This name is already in use!")
            folder?.delete()
            navigationController?.popViewController(animated: true)
            return
        }
        
        if nameTextField.text == folder!.name{
            navigationController?.popViewController(animated: true)
            return
        }
        
        if viewMode == "Edit" {
            delegate?.onNameChanged(name: nameTextField.text!)
        } else {
            folder!.name = nameTextField.text
            delegate?.onNewFolder(folder: folder!)
        }
        
        navigationController?.popViewController(animated: true)
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

