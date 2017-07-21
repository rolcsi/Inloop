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
        
        let optionalUrl = URL(string: Constants.ordersUrl)
        
        
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
    
    func checkFields() {
        
        guard let text = self.nameTextField.text,
            text.characters.count > 4 else {
            
            self.showAlert(text: "Name must be at least 5 characters")
            return
        }
        
        guard let phone = self.phoneTextField.text,
            phone.characters.count > 4 else {
                
                self.showAlert(text: "Phone must be at least 5 characters")
                return
        }
    }
    
    func showAlert(text: String) {
        
        let alertController = UIAlertController(title: "Alert", message: text, preferredStyle: .alert)
        self.present(alertController, animated: true) { 
            
            print("alert shown")
        }
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        
        //self.checkFields()
        
        var parameters: [String: Any] = [:]
        parameters["name"] = "010101"
        parameters["phone"] = 0909009
        
        let optionalUrl = URL(string: Constants.addUrl)
        
        guard let url = optionalUrl else { return }
        
        let request = Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default)
        request.responseJSON { (response) in
            
            if case .success(_) = response.result {
                
                print("added")
            }
        }
    }
}

extension AddViewController: UITextFieldDelegate {
    
}
