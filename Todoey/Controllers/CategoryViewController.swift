//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Anna Shark on 9/9/21.
//  Copyright © 2021 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
    let realm = try! Realm()
    
    var categories : Results<Category>?


    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCats()
        tableView.separatorStyle = .none
    }


//MARK: - TableView DataSource Methods
    // to display all the categories from the persistant container
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.textLabel?.text = categories?[indexPath.row].name ?? "No categories added yet"
        cell.backgroundColor = RandomFlatColor()
        
        return cell
    }
//MARK: - TableView Data Manipulation methods
    // save data and load data to use CRUD
    
    func save(category: Category) {
        
        do {
            try realm.write{
                realm.add(category)
            }
        } catch {
            print("Error saving context\(error)")
        }
        tableView.reloadData()
    }
    
    
    func loadCats(/*with request: NSFetchRequest<Category> = Category.fetchRequest()*/) {
        categories = realm.objects(Category.self)
        tableView.reloadData()
    }
    
//MARK: - Delete Data from Swipe
    override func updateModel(at indexPath: IndexPath) {
                    if let cat = self.categories?[indexPath.row] {
                       do  {
                        try self.realm.write {
                            self.realm.delete(cat)
                        }
                       } catch {
                        print("Error deleting category, \(error)")
                       }
                    }

    }
//MARK: - Add New Categories

    // add new categories using Category entity
   
    @IBAction func addCatButtonPressed(_ sender: UIBarButtonItem) {
    
        var textField = UITextField()

        let alert = UIAlertController(title: "Add new list", message: "", preferredStyle: .alert)

        let action = UIAlertAction(title: "Add category", style: .default) { (action) in
            // what will happen once user clicks add item button on alert


            let newCat = Category()
            newCat.name = textField.text!

            self.save(category: newCat)

        }
        alert.addAction(action)
        alert.addTextField { (alertTextField) in
            textField = alertTextField
            alertTextField.placeholder = "Type here your new item"
            
        }
       

        present(alert, animated: true, completion: nil)
    }
//MARK: - TableView Delegate methods
    //leave for later what should happen when we click category
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: K.segueIdentifier, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
    }
}

