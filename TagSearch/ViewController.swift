//
//  ViewController.swift
//  TagSearch
//
//  Created by N Sankar on 14/10/15.
//  Copyright © 2015 N Sankar. All rights reserved.
//

import UIKit

let dbName = "localSqliteDb"
let tableCreationQuery = ["CREATE TABLE Description(desId INTEGER PRIMARY KEY AUTOINCREMENT,descriptionDetail TEXT)",
    "CREATE TABLE TagDetails(tagId INTEGER PRIMARY KEY AUTOINCREMENT,tagName TEXT,tagRefId INTEGER REFERENCES Description(desId) ON UPDATE CASCADE)"]

class ViewController: UIViewController, UISearchBarDelegate, UISearchDisplayDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var descriptionTextView : UITextView!
    @IBOutlet weak var tagName : UITextField!
    @IBOutlet weak var searchBar : UISearchBar!
    @IBOutlet weak var searchResultTableView : UITableView!
    
    var searchResultArray: [NSDictionary] = []
    
    var sqliteWrapper : SqliteWrapper = SqliteWrapper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createTable()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        searchResultTableView.delegate = self
        searchResultTableView.dataSource = self
        searchBar.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func createTable(){
        sqliteWrapper.createDatabase(dbName)
        for query in tableCreationQuery{
            sqliteWrapper.executeQuery(query)
        }
    }
    
    @IBAction func submitTag(){
        let selectQuery = "SELECT * FROM Description WHERE descriptionDetail = '\(descriptionTextView.text)'"
        let responseArray = sqliteWrapper.executeAnyQuery(selectQuery)
        if (responseArray.count > 0){
            for entry in responseArray{
                if let indEntry:NSDictionary = entry as? NSDictionary{
                    if ((indEntry.valueForKey("descriptionDetail") as! String) == descriptionTextView.text){
                        insertIntoTagTable(indEntry)
                    }
                }
            }
        }else{
            let alertDescription = "Description detail mentioned above is not added! Please add add and then tag.."
            let alertTitle = "Description not added"
            let alertController : UIAlertController = UIAlertController(title: alertTitle, message: alertDescription, preferredStyle: UIAlertControllerStyle.Alert)
            let alertAction : UIAlertAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil)
            alertController.addAction(alertAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    func insertIntoTagTable(indEntry : NSDictionary){
        let selectQuery = "SELECT * FROM TagDetails WHERE tagName = '\(tagName.text!)'"
        let responseArray = sqliteWrapper.executeAnyQuery(selectQuery)
        if (responseArray.count == 0){
        
        let desId = indEntry.valueForKey("desId") as! String
        let tagInsertQuery = "INSERT INTO TagDetails (tagName,tagRefId) VALUES ('\(tagName.text!)',\(desId))"
        sqliteWrapper.executeQuery(tagInsertQuery)
        }
    }
    
    @IBAction func submitDescription(){
        let selectQuery = "SELECT * FROM Description WHERE descriptionDetail = '\(descriptionTextView.text)'"
        let responseArray = sqliteWrapper.executeAnyQuery(selectQuery)
        if (responseArray.count == 0){
            let insertQuery = "INSERT INTO Description (descriptionDetail) VALUES ('\(descriptionTextView.text)')"
            sqliteWrapper.executeQuery(insertQuery)
        }else{
            let alertDescription = "Description already added, please add a new one!"
            let alertTitle = "Duplicate Entry"
            let alertController : UIAlertController = UIAlertController(title: alertTitle, message: alertDescription, preferredStyle: UIAlertControllerStyle.Alert)
            let alertAction : UIAlertAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil)
            alertController.addAction(alertAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    
    //Search bar delegates
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        let searchQuery = "SELECT * FROM TagDetails where tagName LIKE '\(searchBar.text!)'"
        let responseArray = sqliteWrapper.executeAnyQuery(searchQuery)
        if (responseArray.count != 0){
            if let localArray = responseArray as? [NSDictionary]{
                
                for item : NSDictionary in localArray{
                    if let refId = item.valueForKey("tagRefId"){
                        let searchQueryDes = "SELECT * FROM Description where desId = \(refId)"
                        if let responseArrayDes = sqliteWrapper.executeAnyQuery(searchQueryDes) as? [NSDictionary]{
                        self.searchResultArray.appendContentsOf(responseArrayDes)
                        }
                        
                    }
                }
                self.searchResultTableView.reloadData()
            }
        }
    }
    
    
    //table view delegates
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResultArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier:"Cell")
        let indDict = searchResultArray[indexPath.row]
        cell.textLabel?.text = indDict.valueForKey("descriptionDetail") as? String
        cell.detailTextLabel?.text = "Result corresponding to tag = \(searchBar.text!)"
        return cell;
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 72
    }
    
    
}

