//
//  TableViewController.swift
//  task5
//
//  Created by Stanislav on 12.11.2019.
//  Copyright © 2019 Stanislav. All rights reserved.
//

import UIKit
import CoreData

protocol FolderDelegate
{
    func onNameChanged(name: String)
    func onNewFolder(name : String)
}

class TableViewController: UITableViewController, FolderDelegate {
    
    func onNewFolder(name: String) {
        saveFolder(name: name)
    }
    
    func onNameChanged(name: String) {
        renameFolder(name: name)
    }

    @IBOutlet weak var addBarButton: UIBarButtonItem!
    @IBOutlet weak var editBarButton: UIBarButtonItem!
    
    
    var subFolders = [NSManagedObject]()
    var rootFolder : NSManagedObject?
    static var bufferFolder : NSManagedObject?
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var managedContext : NSManagedObjectContext {
        return appDelegate.persistentContainer.viewContext
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getRootFolder()
        reloadData()
        setupGestureRecognizer()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return subFolders.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath)
        
        let folder = subFolders[indexPath.row]
        cell.textLabel!.text = folder.value(forKey: "name") as? String
        cell.detailTextLabel?.text = "Subfolders: " + String(getSubFoldersCount(folder: folder))
            + " / Total: " + String(getTotalSubFoldersCount(folder: folder))
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if getSubFoldersCount(folder: self.subFolders[indexPath.row]) != 0
            {
                showAlert(message: "Are you sure you want to delete record with " + String(getSubFoldersCount(folder: self.subFolders[indexPath.row])) + " child records?", folder: self.subFolders[indexPath.row])
            } else {
                deleteFolder(folder: self.subFolders[indexPath.row])
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let tableViewController = storyBoard.instantiateViewController(withIdentifier: "tableView") as! TableViewController
        tableViewController.rootFolder = subFolders[indexPath.row]
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
                showLongPressMenu(folder: subFolders[indexPath.row])
            } else {
                showLongPressMenu(folder: rootFolder!)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let FolderViewController = segue.destination as? FolderViewController else { return }
    
        if sender is UIBarButtonItem {
            let button = sender as? UIBarButtonItem
            FolderViewController.viewMode = button?.title
        }
        FolderViewController.folder = rootFolder
        FolderViewController.delegate = self
    }
 
    func showAlert(message : String, folder : NSManagedObject){
        let alertController = UIAlertController(title: "Warning", message: message, preferredStyle: .alert)
        let acceptAction = UIAlertAction(title: "OK", style: .default) { (action) in
            self.deleteFolder(folder: folder)
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
    
    func showLongPressMenu(folder : NSManagedObject) {
        let alertController = UIAlertController(title: nil, message: "Choose option", preferredStyle: .actionSheet)
        let copyAction = UIAlertAction(title: "Copy", style: .default) { (action) in
            let entity =  NSEntityDescription.entity (forEntityName: "Folder",
                                                      in: self.managedContext)
            let folderCopy = NSManagedObject(entity: entity!,
                                             insertInto: self.managedContext)
            folderCopy.setValue(folder.value(forKey: "name"), forKey: "name")
            self.cloneFolder(fromFolder: folder, intoFolder: folderCopy)
            TableViewController.bufferFolder = folderCopy
        }
        let moveAction = UIAlertAction(title: "Move", style: .default) { (action) in
            TableViewController.bufferFolder = folder
            self.deleteFolder(folder: folder)
        }
        let deleteAction = UIAlertAction(title: "Delete", style: .default) { (action) in
            if self.getSubFoldersCount(folder: folder) != 0
            {
                self.showAlert(message: "Are you sure you want to delete record with " + String(self.getSubFoldersCount(folder: folder)) + " child records?", folder: folder)
            } else {
                self.deleteFolder(folder: folder)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(copyAction)
        alertController.addAction(moveAction)
        
        if TableViewController.bufferFolder != nil {
            let pastAction = UIAlertAction(title: "Past", style: .default) { (action) in
                self.insertFolder(rootFolder: folder, subFolder: TableViewController.bufferFolder!)
            }
            alertController.addAction(pastAction)
        }
        
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        self.present(alertController, animated: true)
    }
    
}

extension TableViewController {
    
    func cloneFolder(fromFolder: NSManagedObject, intoFolder: NSManagedObject) {
        if getSubFoldersCount(folder: fromFolder) == 0 {
            return
        }
        let subFolders = fromFolder.value(forKey: "subFolders") as! NSSet
        for f in subFolders {
            let ff = f as! NSManagedObject
            let entity =  NSEntityDescription.entity (forEntityName: "Folder",
                                                      in: managedContext)
            let folderCopy = NSManagedObject(entity: entity!,
                                             insertInto:managedContext)
            folderCopy.setValue(ff.value(forKey: "name"), forKey: "name")
            folderCopy.setValue(intoFolder, forKey: "owner")
            cloneFolder(fromFolder: ff, intoFolder: folderCopy)
        }
    }
    
    func saveFolder(name: String) {
        let entity =  NSEntityDescription.entity (forEntityName: "Folder",
                                                  in: managedContext)
        let folder = NSManagedObject(entity: entity!,
                                     insertInto:managedContext)
        folder.setValue(name, forKey: "name")
        rootFolder?.mutableSetValue(forKey: "subFolders").add(folder)
        do {
            try managedContext.save()
        } catch {
            print("Failed saving")
        }
        reloadData()
    }
    
    func getSubFoldersCount(folder : NSManagedObject) -> Int {
        let subFolders = folder.value(forKey: "subFolders") as! NSSet
        return subFolders.count
    }
    
    func getTotalSubFoldersCount(folder : NSManagedObject) -> Int {
        var count = 0
        let subFolders = folder.value(forKey: "subFolders") as! NSSet
        for f in subFolders {
            let ff = f as! NSManagedObject
            count += 1 + getTotalSubFoldersCount(folder: ff)
        }
        return count
    }
    
    func deleteFolder(folder : NSManagedObject) {
        managedContext.delete(folder)
        do {
            try managedContext.save()
        } catch {
            print("Failed saving")
        }
        reloadData()
    }
    
    func renameFolder(name: String) {
        navigationItem.title = name
        
        rootFolder!.setValue(name, forKey: "name")
        
        do {
            try managedContext.save()
        } catch {
            print("Failed saving")
        }
    }
    
    func insertFolder(rootFolder: NSManagedObject, subFolder: NSManagedObject) {
        let rootFolderSubFolders = rootFolder.value(forKey: "subFolders") as! NSSet
        for f in rootFolderSubFolders {
            let ff = f as! NSManagedObject
            if ff.value(forKey: "name") as! String == subFolder.value(forKey: "name") as! String {
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
            }
        }
        rootFolder.mutableSetValue(forKey: "subFolders").add(subFolder)
        do {
            try managedContext.save()
        } catch {
            print("Failed saving")
        }
        reloadData()
    }
    
    fileprivate func getRootFolder() {
        if rootFolder == nil {
            navigationItem.title = "Root folder"
            navigationItem.rightBarButtonItems = [addBarButton]
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Folder")
            request.returnsObjectsAsFaults = false
            do {
                let result = try managedContext.fetch(request)
                let foldersList = result as! [NSManagedObject]
                guard !foldersList.isEmpty else {
                    let entity =  NSEntityDescription.entity (forEntityName: "Folder",
                                                              in: managedContext)
                    let folder = NSManagedObject(entity: entity!,
                                                 insertInto:managedContext)
                    folder.setValue("Root folder", forKey: "name")
                    rootFolder = folder
                    
                    do {
                        try managedContext.save()
                    } catch {
                        print("Failed saving")
                    }
                    return
                }
                rootFolder = foldersList[0]
            } catch {
                print("Failed")
            }
        } else {
            navigationItem.title = rootFolder?.value(forKey: "name") as? String
            navigationItem.rightBarButtonItems = [addBarButton, editBarButton]
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
    }
    
    func reloadData(){
        let subFolders = rootFolder!.value(forKey: "subFolders") as! NSSet
        self.subFolders.removeAll()
        for f in subFolders {
            if f is NSManagedObject {
                let ff = f as! NSManagedObject
                self.subFolders.append(ff)
            }
        }
        tableView.reloadData()
    }
}
