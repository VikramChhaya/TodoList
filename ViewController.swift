//
//  ViewController.swift
//  TodoList
//
//  Created by Chhaya on 21/04/17.
//  Copyright © 2017 Chhaya. All rights reserved.
//

import UIKit
import Realm


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate
{
   
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var currentCreateAction:UIAlertAction!
    
    let realm = RLMRealm.default()
    
    var todoList = ToDoItem.allObjects()
    
    var isEditingMode = false
    
    var searchActive : Bool = false
    
    var data:[String] = []//ToDoItem.mutableArrayValue(forKey: "detail") as! [String]
    var filtered:[String] = []
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell") //1
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        readTasksAndUpdateUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didClickOnEditButton(_ sender: UIBarButtonItem) {
        isEditingMode = !isEditingMode
        self.tableView.setEditing(isEditingMode, animated: true)
        let b = sender as UIBarButtonItem
        if isEditingMode == true{
            b.title="Done"
        }
        else{
            b.title="Edit"
        }
        
    }
 // To Update table view
    func readTasksAndUpdateUI(){
        
        todoList = ToDoItem.allObjects()
        self.tableView.setEditing(false, animated: true)
        self.tableView.reloadData()
    }

    //To create action of the alert only if textfield text is not empty
    func listNameFieldDidChange(_ textField:UITextField){
        self.currentCreateAction.isEnabled = (textField.text?.characters.count)! > 0
    }
    
    func displayAlertToAddTaskList(_ updatedList:ToDoItem!){
        
        var title = "New Tasks List"
        var doneTitle = "Create"
        if updatedList != nil{
            title = "Update Tasks List"
            doneTitle = "Update"
        }
        
        let alertController = UIAlertController(title: title, message: "Write the name of your tasks list.", preferredStyle: UIAlertControllerStyle.alert)
        let createAction = UIAlertAction(title: doneTitle, style: UIAlertActionStyle.default) { (action) -> Void in
            
            let listName = alertController.textFields?.first?.text
            
            if updatedList != nil{
                // update mode
                try! self.realm.transaction(){
                    updatedList.detail = listName!
                    self.readTasksAndUpdateUI()
                }
            }
            else{
                
                let newTaskList = ToDoItem()
                newTaskList.detail = listName!
                
                try! self.realm.transaction(){
                    
                    self.realm.add(newTaskList)
                    self.readTasksAndUpdateUI()
                }
            }
            
            print(listName ?? "")
        }
        
        alertController.addAction(createAction)
        createAction.isEnabled = false
        self.currentCreateAction = createAction
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        
        alertController.addTextField { (textField) -> Void in
            textField.placeholder = "Task List Name"
            textField.addTarget(self, action: #selector(ViewController.listNameFieldDidChange(_:)), for: UIControlEvents.editingChanged)
            if updatedList != nil{
                textField.text = updatedList.detail
            }
        }
        
        self.present(alertController, animated: true, completion: nil)
    }

    
    ////For popover
    @IBAction func showPopover(_ sender: UIButton) {
        
        let ac = UIAlertController(title: "Arrange", message: "", preferredStyle: .actionSheet)
        let dismissHandler = {
            (action: UIAlertAction!) in
            self.dismiss(animated: true, completion: nil)
        }
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: dismissHandler))
        
        let byNameActionButton = UIAlertAction(title: "By Name", style: .default) { action -> Void in
            print("Arrenge By Name")
            self.todoList = self.todoList.sortedResults(usingKeyPath: "detail", ascending: true)
            self.tableView.reloadData()
        }
        ac.addAction(byNameActionButton)
        
        let byDateActionButton = UIAlertAction(title: "By Date/Time", style: .default) { action -> Void in
            print("Arrange By Date/Time")
            self.todoList = self.todoList.sortedResults(usingKeyPath: "createdAt", ascending: false)
            self.tableView.reloadData()
        }
        ac.addAction(byDateActionButton)
        
        let popover = ac.popoverPresentationController
        
        let viewForSource = sender as UIView
        popover?.sourceView = viewForSource as UIView
        popover?.sourceRect = viewForSource.bounds
        
        present(ac, animated: true)
        
    }
    
    
    
    // MARK: UITableViewDataSource
    // [2]
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as UITableViewCell
        
        let index = UInt(indexPath.row)
        let item = todoList.object(at: index) as! ToDoItem // [4]
       
        cell.backgroundColor = UIColor(colorLiteralRed: 0.0, green: 0.5, blue: 0.4, alpha: 0.5)
        let date = item.createdAt
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date as Date)
        if(searchActive){
            cell.textLabel?.text = filtered[indexPath.row]
        } else {
        cell.textLabel!.text = dateString+"->"+item.detail
        }
        return cell
    }
    
    // [3]
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // [4]
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(searchActive) {
            return filtered.count
        }
        return Int(todoList.count);
        //return Int(todoList.count)
    }
    
    @IBAction func addToDo(_ sender: Any) {
        
        let alertController : UIAlertController = UIAlertController(title: "New Todo", message: "What do you plan to do?", preferredStyle: .alert)
        
        alertController.addTextField { (UITextField) in
            
        }
        
        let action_cancel = UIAlertAction.init(title: "Cancel", style: .cancel) { (UIAlertAction) -> Void in
            
        }
        alertController.addAction(action_cancel)
        
        let action_add = UIAlertAction.init(title: "Add", style: .default) { (UIAlertAction) -> Void in
            
            let textField_todo = (alertController.textFields?.first)! as UITextField
            
            //print("You entered \(textField_todo.text)")
            
            let todoItem = ToDoItem() // [1]
            todoItem.detail = textField_todo.text!
            todoItem.status = 0
            
            try! self.realm.transaction(){
                self.realm.add(todoItem)
            }
                self.tableView.insertRows(at: [IndexPath.init(row: Int(self.todoList.count)-1, section: 0)], with: .automatic)
          //  })
            
        }
        
        alertController.addAction(action_add)
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
          }
    // [1]
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete") { (deleteAction, indexPath) -> Void in
            
            //Deletion will go here
            
            let item = self.todoList[UInt(indexPath.row)]
            try! self.realm.transaction(){
                self.realm.delete(item)
            }
                self.readTasksAndUpdateUI()
            
        }
        let editAction = UITableViewRowAction(style: UITableViewRowActionStyle.normal, title: "Edit") { (editAction, indexPath) -> Void in
            
            // Editing will go here
            let listToBeUpdated = self.todoList[UInt(indexPath.row)]
            self.displayAlertToAddTaskList(listToBeUpdated as! ToDoItem)
            
        }
        /*let doneAction = UITableViewRowAction(style: UITableViewRowActionStyle.normal, title: "Done") { (doneAction, indexPath) -> Void in
            // Editing will go here
            
                self.readTasksAndUpdateUI()
            }
*/
        return [deleteAction, editAction]
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        data = todoList.mutableArrayValue(forKey: "detail") as! [String]
        filtered = data.filter({ (text) -> Bool in
            let tmp: NSString = text as NSString
            let range = tmp.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
            return range.location != NSNotFound
        })
        if(filtered.count == 0){
            searchActive = false;
        } else {
            searchActive = true;
        }
        self.tableView.reloadData()
    }

    
  }


