//
//  OrdersViewController.swift
//  Inloop
//
//  Created by Roland Beke on 19.7.17.
//  Copyright © 2017 Roland Beke. All rights reserved.
//

import UIKit
import Alamofire
import DATASource
import Sync

public protocol StackVC {
    
    func setDataStack(dataStack: DataStack)
}

public protocol UserVC {
    
    func setUserId(userId: String)
}

class OrdersViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let dataStack = DataStack(modelName: "Model")
    
    static let detailIdentifier = "showDetail"
    static let addIdentifier = "showAdd"
    
    lazy var dataSource: DATASource = {
        
        let request: NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CDUser")
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true), NSSortDescriptor(key: "phone", ascending: true), NSSortDescriptor(key: "id", ascending: true)]
        
        let dataSource = DATASource(tableView: self.tableView, cellIdentifier: "OrderTableViewCell", fetchRequest: request, mainContext: self.dataStack.mainContext, configuration: { cell, item, indexPath in
            
            guard let cell = cell as? OrderTableViewCell else {
                fatalError("\(OrderTableViewCell.self) not loaded")
            }
            
            cell.nameLabel.text = String.bindNilOrEmpty(item.value(forKey: "name"))
            cell.phoneLabel.text = String.bindNilOrEmpty(item.value(forKey: "phone"))
            cell.photoImageView.image = #imageLiteral(resourceName: "photoPlaceholder")
            cell.photoImageView.downloadImage(from: item.value(forKey: "pictureUrl"))
        })
        
        return dataSource  
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.dataSource = self.dataSource
        self.setNavigationItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.checkForOrders()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        let vc = segue.destination as? StackVC
        vc?.setDataStack(dataStack: dataStack)
        
        if let detailVC = segue.destination as? UserVC {
            
            guard let user = sender as? CDUser, let userId = user.id else { return }
            
            detailVC.setUserId(userId: userId)
        }
    }
    
    // MARK: Private methods
    
    private func setNavigationItems() {
        
        self.navigationItem.title = "Orders"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(OrdersViewController.addButtonAction))
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }

    @objc private func addButtonAction() {
        
        self.performSegue(withIdentifier: OrdersViewController.addIdentifier, sender: nil)
    }
    
    private func checkForOrders() {
        
        let optionalUrl = URL(string: Constants.ordersUrl)
        
        guard let url = optionalUrl else { return }
        
        let request = Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default)
        request.responseJSON { (response) in
            
            if case .success(let json) = response.result {
                
                guard let dict = json as? NSDictionary,
                    let items = dict["items"] as? [[String : Any]]
                    else { return }
                
                self.dataStack.performInNewBackgroundContext { context in
                    
                    context.sync(items, inEntityNamed: "CDUser", completion: { (error) in
                        
                        guard let _ = error else { return }
                        
                        let alert = UIAlertController.simpleAlert(text: "Sync error")
                        self.present(alert, animated: true)
                    })
                }
            }
        }
    }
}

extension OrdersViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let user = self.dataSource.object(indexPath) else { return }
        
        self.performSegue(withIdentifier: OrdersViewController.detailIdentifier, sender: user)
    }
}
