//
//  DetailViewController.swift
//  Inloop
//
//  Created by Roland Beke on 19.7.17.
//  Copyright © 2017 Roland Beke. All rights reserved.
//

import UIKit
import Sync

class DetailViewController: UIViewController, StackVC {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var phoneLabel: UILabel!
    
    var dataStack: DataStack?
    var userId: Int64?
    private var user: CDUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        guard let userId = self.userId,
            let user = try? self.dataStack?.mainContext.fetch(userId, inEntityNamed: "CDUser")
            else { return }
        
        self.user = user as? CDUser
        
        self.navigationItem.title = self.user?.name
        self.phoneLabel.text = self.user?.phone
    }
}
