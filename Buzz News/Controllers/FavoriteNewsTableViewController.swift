//
//  FavoriteNewsTableViewController.swift
//  Buzz News
//
//  Created by Sagar Choudhary on 11/12/18.
//  Copyright © 2018 Sagar Choudhary. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class FavoriteNewsTableViewController: UITableViewController {
    
    // MARK: Properties
    var ref: DatabaseReference!
    var newsList: [DataSnapshot]! = []
    fileprivate var _refHandle: DatabaseHandle!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureDatabase()
    }
    
    // MARK: Configure Firebase Database
    fileprivate func configureDatabase() {
        
        // get database reference
        ref = Database.database().reference()
        
        _refHandle = ref.child("news").observe(.childAdded) {
            (snapshot: DataSnapshot) in
            self.newsList.append(snapshot)
            self.tableView.insertRows(at: [IndexPath(row: (self.newsList.count-1), section: 0)], with: .fade)
        }
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "favoriteCell") as! FavoriteNewsCell
        
        let newsSnapshot: DataSnapshot = newsList[indexPath.row]
        let news = newsSnapshot.value as! [String: String]
        let title = news[Constants.GuardianResponseKeys.Title] ?? "[title]"
        
        cell.title.text = title
        
        // if url is present
        if let thumbnailUrl = news[Constants.GuardianResponseKeys.Thumbnail] {
            
            cell.activityIndicator.startAnimating()
            
            // dowload the cell image
            APIClient.shared.downloadImage(imageUrl: thumbnailUrl) {
                (image, error) in
                
                // guard for the error
                guard error == nil else {
                    cell.activityIndicator.stopAnimating()
                    self.showAlertMessage(message: error!)
                    return
                }
                DispatchQueue.main.async {
                    cell.cellImage.image = UIImage(data: image!)
                    cell.activityIndicator.stopAnimating()
                }
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // MARK: Add favorite delete functionality
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            let newsSnapshot: DataSnapshot = newsList[indexPath.row]
            ref.child("news").child(newsSnapshot.key).removeValue()
            self.newsList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}