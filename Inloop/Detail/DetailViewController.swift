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
import MessageUI

class DetailViewController: UIViewController, StackVC, UserVC {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var phoneLabel: UILabel!

    private var userId: String?
    private weak var dataStack: DataStack?

    lazy var dataSource: DATASource = {

        let request: NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CDItem")
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true),
                                   NSSortDescriptor(key: "count", ascending: true)]

        guard let user = self.user(for: self.userId) else {
            fatalError("User with id: \(String(describing: self.userId)) not found")
        }
        request.predicate = NSPredicate(format: "user = %@", user)

        guard let dataStack = self.dataStack else {
            fatalError("DataStack wasn't injected to \(DetailViewController.self)")
        }

        let dataSource = DATASource(tableView: self.tableView,
                                    cellIdentifier: "DetailTableViewCell",
                                    fetchRequest: request,
                                    mainContext: dataStack.mainContext,
                                    configuration: { cell, item, _ in

            guard let cell = cell as? DetailTableViewCell else {
                fatalError("\(DetailTableViewCell.self) not loaded")
            }

            cell.nameLabel.text = String.bindNilOrEmpty(item.value(forKey: "name"))
            cell.countLabel.text = String.bindNilOrEmpty(item.value(forKey: "count"))
        })

        return dataSource
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.dataSource = self.dataSource
        self.setNavigationItems()
        self.checkForItems()
    }

    // MARK: Protocols methods

    func setUserId(userId: String) {

        self.userId = userId
    }

    func setDataStack(dataStack: DataStack) {

        self.dataStack = dataStack
    }

    // MARK: Private methods

    private func setNavigationItems() {

        guard let id = self.userId,
            let fetch = try? self.dataStack?.fetch(id, inEntityNamed: "CDUser"),
            let user = fetch as? CDUser
            else {
                return
        }

        self.navigationItem.title = String.bindNilOrEmpty(user.name)
        self.phoneLabel.text = String.bindNilOrEmpty(user.phone)
    }

    // Move up attr "id" from childDict called "id"
    private func modifyDict(items: [[String : Any]]) -> [[String: Any]] {

        var newItems: [[String: Any]] = []

        for var item in items {
            let idDict = item["id"] as? [String: Any]
            item["id"] = idDict?["id"]
            newItems.append(item)
        }

        return newItems
    }

    private func user(for id: String?) -> CDUser? {

        guard let id = id,
            let fetch = try? self.dataStack?.fetch(id, inEntityNamed: "CDUser"),
            let user = fetch as? CDUser
            else {

                let alert = UIAlertController.simpleAlert(text: "User not found in db.", completion: {

                    self.navigationController?.popViewController(animated: true)
                })
                self.navigationController?.present(alert, animated: true)
                return nil
        }

        return user
    }

    private func checkForItems() {

        let optionalUrl = URL(string: Constants.detailUrl + self.userId!)

        guard let url = optionalUrl else { return }

        let request = Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default)
        request.responseJSON { (response) in

            if case .success(let json) = response.result {

                guard let dict = json as? NSDictionary,
                    let items = dict["items"] as? [[String : Any]]
                    else { return }

                let newItems = self.modifyDict(items: items)

                guard let user = self.user(for: self.userId) else { return }

                self.dataStack?.sync(newItems, inEntityNamed: "CDItem", parent: user, completion: { (error) in

                    guard let _ = error else { return }

                    let alert = UIAlertController.simpleAlert(text: "Sync error.")
                    self.present(alert, animated: true)
                })
            }
        }
    }

    fileprivate func configuredMailComposeViewController() -> MFMailComposeViewController {

        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self

        guard let user = self.user(for: self.userId),
            let name = user.name
            else { return mailComposerVC }

        mailComposerVC.setToRecipients([name + Constants.mailDomain])

        return mailComposerVC
    }
}

extension DetailViewController: MFMailComposeViewControllerDelegate {

    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult,
                               error: Error?) {

        controller.dismiss(animated: true, completion: nil)
    }
}

extension DetailViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: true)

        let mailComposeViewController = self.configuredMailComposeViewController()

        if MFMailComposeViewController.canSendMail() {

            self.present(mailComposeViewController, animated: true, completion: nil)
        }
    }
}
