//
//  ViewController.swift
//  CodableCoreData
//
//  Created by Suresh Shiga on 02/12/19.
//  Copyright © 2019 Test. All rights reserved.
// https://medium.com/swlh/core-data-using-codable-68660dfb5ce8

import UIKit
import CoreData
import Foundation

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var data = [NSManagedObject]()
    var container: NSPersistentContainer!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        setupPersistContainer()
        retrieveDataFromURL()
        loadSaveData()
    }
    
    // Persist Container
    
    private func setupPersistContainer() {
        container = NSPersistentContainer(name: "CoreDatacodable")
        container.loadPersistentStores { (storeDescription, error) in
            self.container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            if let error = error {print("Unresolved error \(error)")
            }
        }
    }
    
    // Retrieve Data From URL
    
    private func retrieveDataFromURL(){
        let gitURL = URL(string: "https://api.github.com/repos/apple/swift/commits?per_page=100")!
        URLSession.shared.dataTask(with: gitURL) { (data, response, error) in
            guard let data = data else {fatalError("load data error")}
            do {
                let commitdData = try JSONDecoder().decode([CommitNode].self, from: data)
                DispatchQueue.main.async { [weak  self] in
                    guard let self = self else {return}
                    for commitNode in commitdData {
                        let commit = User(context: self.container.viewContext)
                        self.configure(user: commit, usingNode: commitNode)
                    }
                    self.saveContext()
                    self.loadSaveData()
                }
            } catch {
                print("loading error due to: \(error)")}}.resume()}
    
    // Configure Data to Usre Model
    
    private func configure(user: User, usingNode: CommitNode) {
        user.sha = usingNode.sha
        user.message = usingNode.commit.message
        user.url    = usingNode.html_url
        let formatter = ISO8601DateFormatter()
        user.date = (formatter.date(from: usingNode.commit.committer.date)! as NSDate)
    }
    
    // Save Context
    
    private func saveContext(){
        if container.viewContext.hasChanges {
            do {
                try container.viewContext.save()
            } catch {
                print("An error occurred while saving: \(error)")}}}
    
    // Load Save Data
    
    private func loadSaveData(){
        let request:NSFetchRequest<User> = User.fetchRequest()
        let sort = NSSortDescriptor(key: "date", ascending: false)
        request.sortDescriptors = [sort]
        
        do {
            data = try container.viewContext.fetch(request)
            tableView.reloadData()
        } catch  {
            print("Fetch failed")
        }
    }
}


// MARK:- TABLEVIEW EXTENSION


extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        cell.textLabel?.text = (data[indexPath.row] as! User).message
        cell.detailTextLabel?.text = (data[indexPath.row] as! User).date?.description
        return cell
    }
    
}


// MARK:- Model


struct CommitNode: Codable {
    var commit: GitCommit
    var sha: String
    var html_url: String
}

struct GitCommit: Codable {
    var message: String
    var committer: Committer
}

struct Committer: Codable {
    var date: String
}

