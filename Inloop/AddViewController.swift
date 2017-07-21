//
//  AddViewController.swift
//  Inloop
//
//  Created by Roland Beke on 19.7.17.
//  Copyright © 2017 Roland Beke. All rights reserved.
//

import UIKit
import Alamofire
import Sync

class AddViewController: UIViewController, StackVC {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    
    var dataStack: DataStack?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Add New Contact"
        
        let optionalUrl = URL(string: "https://inloop-contacts.appspot.com/_ah/api/contactendpoint/v1/contact")
        
        
        guard let url = optionalUrl else { return }
        
        let request = Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default)
        request.responseJSON { (response) in
            
            if case .success(let json) = response.result {

                guard let dict = json as? NSDictionary,
                    let items = dict["items"] as? [[String : Any]]
                    else { return }
                
                self.dataStack?.performInNewBackgroundContext { context in
                    
                    context.sync(items, inEntityNamed: "CDUser", completion: { (error) in
                    
                        // TODO: Alert
                        print("sync error: \(String(describing: error))")
                    })
                }
            }
        }
        
    }
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        
    }
}

extension AddViewController: UITextFieldDelegate {
    
}
