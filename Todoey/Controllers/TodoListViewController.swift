//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift

class TodoListViewController: SwipeTableViewController{
    
    var todoItems : Results<Item>?
    let realm = try! Realm()
    var selectedCategory : Category? {
        didSet {
           loadItems()
        }
    }


    
    //let defaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        tableView.rowHeight = 80.0


    }



//MARK: - TableView Datasource methods

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: K.itemCellIdentifier, for: indexPath)
        
        if let item = todoItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            cell.accessoryType = item.done ? .checkmark : .none
        } else {
            cell.textLabel?.text = "No items added"
        }
        
        return cell
    }
    
//MARK: - TableView Delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = todoItems?[indexPath.row] {
           do  {
            try realm.write {
                //realm.delete(item)
                item.done = !item.done
            }
           } catch {
            print("Error saving done status, \(error)")
           }
        }
        
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    

//MARK: - Add New Items
        
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
 
    print("add button pressed")
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new Todoey item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add item", style: .default) { (action) in
            // what will happen once user clicks add item button on alert
            
            //create a new item from data model Item
            // save it
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write{
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                    }
                } catch {
                    print("Error saving new items\(error)")
                }
            }
            self.tableView.reloadData()
            
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Type here your new item"
            textField = alertTextField
        }
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
   
    }
    
    
//MARK: - Model Manilupation Methods

    func loadItems() {
        //todoItems = realm.objects(Item.self)
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }
    
}

//MARK: - SearchBar Delegate  Methods

extension TodoListViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()

            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }

        }
    }
}