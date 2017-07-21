//
//  OrdersViewController.swift
//  Inloop
//
//  Created by Roland Beke on 19.7.17.
//  Copyright © 2017 Roland Beke. All rights reserved.
//

import UIKit
import DATASource
import Sync

public protocol StackVC {
    
    var dataStack: DataStack? { get set }
}

class OrdersViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let dataStack = DataStack(modelName: "Model")
    static let detailIdentifier = "showDetail"
    static let addIdentifier = "showAdd"
    
    lazy var dataSource: DATASource = {
        let request: NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CDUser")
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        let dataSource = DATASource(tableView: self.tableView, cellIdentifier: "OrderTableViewCell", fetchRequest: request, mainContext: self.dataStack.mainContext, configuration: { cell, item, indexPath in
            
            guard let cell = cell as? OrderTableViewCell else {
                fatalError("\(OrderTableViewCell.self) not loaded")
            }
            
            cell.nameLabel.text = item.value(forKey: "name") as? String
            cell.phoneLabel.text = item.value(forKey: "phone") as? String
        })
        
        return dataSource  
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.dataSource = self.dataSource
        
        self.navigationItem.title = "Orders"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(OrdersViewController.addButtonAction))
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        var vc = segue.destination as? StackVC
        vc?.dataStack = self.dataStack
        
        if let detailVC = segue.destination as? DetailViewController {
            
            guard let user = sender as? CDUser else { return }
            
            detailVC.userId = user.id
        }
    }

    @objc private func addButtonAction() {
        
        self.performSegue(withIdentifier: OrdersViewController.addIdentifier, sender: nil)
    }
}

extension OrdersViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let user = self.dataSource.object(indexPath) else { return }
        
        //self.dataStack.mainContext.delete(user)
        self.performSegue(withIdentifier: OrdersViewController.detailIdentifier, sender: user)
    }
}
