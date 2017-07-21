//
//  DetailViewController.swift
//  Inloop
//
//  Created by Roland Beke on 19.7.17.
//  Copyright © 2017 Roland Beke. All rights reserved.
//

import UIKit
import Sync
import DATASource
import Alamofire

class DetailViewController: UIViewController, StackVC {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var phoneLabel: UILabel!
    
    var dataStack: DataStack?
    var userId: Int64?
    private var user: CDUser?
    
    lazy var dataSource: DATASource = {
        let request: NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CDItem")
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true), NSSortDescriptor(key: "count", ascending: true)]
        request.predicate = NSPredicate(format: "user.id = \(self.userId!)")
        
        guard let dataStack = self.dataStack else {
            fatalError("DataStack wasn't injected to \(DetailViewController.self)")
        }
        
        let dataSource = DATASource(tableView: self.tableView, cellIdentifier: "DetailTableViewCell", fetchRequest: request, mainContext: dataStack.mainContext, configuration: { cell, item, indexPath in
            
            guard let cell = cell as? DetailTableViewCell else {
                fatalError("\(DetailTableViewCell.self) not loaded")
            }
            
            cell.nameLabel.text = item.value(forKey: "name") as? String
            
            guard let count = item.value(forKey: "count") else { return }
            cell.countLabel.text = String(describing: count)
        })
        
        return dataSource
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        guard let userId = self.userId,
            let user = try? self.dataStack?.mainContext.fetch(userId, inEntityNamed: "CDUser")
            else { return }
        
        self.user = user as? CDUser
        
        self.dataSource.animations = [.update: .none, .move  : .none, .insert: .none]
        self.tableView.dataSource = self.dataSource
        
        self.navigationItem.title = self.user?.name
        self.phoneLabel.text = self.user?.phone
        
        let userIDstr = String(self.userId!)
        let optionalUrl = URL(string: Constants.detailUrl + userIDstr)
        
        guard let url = optionalUrl else { return }
        
        let request = Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default)
        request.responseJSON { (response) in
            
            if case .success(let json) = response.result {
                
                guard let dict = json as? NSDictionary,
                    let items = dict["items"] as? [[String : Any]]
                    else { return }
                
                self.dataStack?.sync(items, inEntityNamed: "CDItem", parent: self.user!, completion: { (error) in
                    
                    // TODO: Alert
                    print("sync error: \(String(describing: error))")
                })
            }
        }
    }
}

