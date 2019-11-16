//
//  TableViewController.swift
//  task5
//
//  Created by Stanislav on 12.11.2019.
//  Copyright © 2019 Stanislav. All rights reserved.
//

import UIKit
import CoreData

class TableViewController: UITableViewController{

    @IBOutlet weak var addBarButton: UIBarButtonItem!
    @IBOutlet weak var editBarButton: UIBarButtonItem!

    static var bufferFolder : Folder?
    static var movingFolder : Folder?
    
    var folder : Folder?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if folder == nil {
            navigationItem.rightBarButtonItems = [addBarButton]
            folder = Folder.getRootFolder()
        } else {
            navigationItem.rightBarButtonItems = [addBarButton, editBarButton]
        }
        navigationItem.title = folder!.name
        reloadData()
        setupGestureRecognizer()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return folder!.subFolders!.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath)
        
        let folder = self.folder!.getSubFolders[indexPath.row]
        cell.textLabel!.text = folder.name
        cell.detailTextLabel?.text = "Subfolders: " + String(folder.subFolders!.count)
            + " / Total: " + String(folder.getTotalSubFoldersCount())
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let selectedFolder = folder!.getSubFolders[indexPath.row]
            if selectedFolder.subFolders!.count != 0
            {
                showAlert(message: "Are you sure you want to delete record with " + String(selectedFolder.subFolders!.count) +
                    " child records?", folder: selectedFolder)
            } else {
                selectedFolder.delete()
                reloadData()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let tableViewController = storyBoard.instantiateViewController(withIdentifier: "tableView") as! TableViewController
        tableViewController.folder = folder!.getSubFolders[indexPath.row]
        self.navigationController?.pushViewController(tableViewController, animated: true)
    }
    
    private func setupGestureRecognizer() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(sender:)))
        longPressGesture.minimumPressDuration = 1.0
        self.view.addGestureRecognizer(longPressGesture)
    }
    
    @objc func handleLongPress(sender: UILongPressGestureRecognizer){
        if sender.state == .began {
            let touchPoint = sender.location(in: self.tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                showLongPressMenu(folder: folder!.getSubFolders[indexPath.row], isTapOnFolder: true)
            } else {
                showLongPressMenu(folder: folder!, isTapOnFolder: false)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let FolderViewController = segue.destination as? FolderViewController else { return }
    
        if sender is UIBarButtonItem {
            let button = sender as? UIBarButtonItem
            FolderViewController.viewMode = button?.title
            if button?.title == "+" {
                let newFolder = Folder()
                newFolder.owner = folder
                FolderViewController.folder = newFolder
            } else {
                FolderViewController.folder = folder
            }
        }
        FolderViewController.onNewFolder = { folder in
            self.folder!.addChild(folder: folder)
            self.reloadData()
        }
        FolderViewController.onNameChanged = { name in
            self.folder?.name = name
            self.navigationItem.title = name
            self.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
    }
    
    func reloadData(){
        tableView.reloadData()
    }
    
}

extension TableViewController {
    
    func showAlert(message : String, folder : Folder){
        let alertController = UIAlertController(title: "Warning", message: message, preferredStyle: .alert)
        let acceptAction = UIAlertAction(title: "OK", style: .default) { (action) in
            folder.delete()
            self.reloadData()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (action) in
        }
        alertController.addAction(acceptAction)
        alertController.addAction(cancelAction)
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        self.present(alertController, animated: true)
    }
    
    func showLongPressMenu(folder : Folder, isTapOnFolder: Bool) {
        let alertController = UIAlertController(title: nil, message: "Choose option", preferredStyle: .actionSheet)
        let copyAction = UIAlertAction(title: "Copy", style: .default) { (action) in
            TableViewController.bufferFolder = folder.clone()
        }
        let moveAction = UIAlertAction(title: "Move", style: .default) { (action) in
            TableViewController.bufferFolder = folder.clone()
            TableViewController.movingFolder = folder
        }
        let deleteAction = UIAlertAction(title: "Delete", style: .default) { (action) in
            if folder.subFolders!.count != 0
            {
                self.showAlert(message: "Are you sure you want to delete record with " + String(folder.subFolders!.count) + " child records?", folder: folder)
            } else {
                folder.delete()
                self.reloadData()
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(copyAction)
        if isTapOnFolder {
            
            alertController.addAction(moveAction)
        }
        
        if TableViewController.bufferFolder != nil {
            let pastAction = UIAlertAction(title: "Past", style: .default) { (action) in
                if self.folder!.isHasSubFolderWithName(name: TableViewController.bufferFolder!.name!) {
                    let alertController = UIAlertController(title: "Erorr", message: "Folder with such name already exist!", preferredStyle: .alert)
                    let cancelAction = UIAlertAction(title: "OK", style: .cancel) { (action) in
                    }
                    alertController.addAction(cancelAction)
                    
                    if let popoverController = alertController.popoverPresentationController {
                        popoverController.sourceView = self.view
                        popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                        popoverController.permittedArrowDirections = []
                    }
                    self.present(alertController, animated: true)
                    return
                } else {
                    if TableViewController.movingFolder != nil {
                        TableViewController.movingFolder!.delete()
                        TableViewController.movingFolder = nil
                    }
                    self.folder!.addChild(folder: TableViewController.bufferFolder!.clone())
                    self.reloadData()
                }
            }
            if TableViewController.movingFolder != nil
                && folder.isHasPerent(folder: TableViewController.movingFolder!) {
            }
            else {
                alertController.addAction(pastAction)
            }
        }
        
        if isTapOnFolder { alertController.addAction(deleteAction) }
        alertController.addAction(cancelAction)
        
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        self.present(alertController, animated: true)
    }

}
