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

class AddViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Add New Contact"
    }
    
    // MARK: Private methods
    
    private func checkFields() -> Bool {
        
        guard let text = self.nameTextField.text,
            text.characters.count > 4 else {
            
            let alert = UIAlertController.simpleAlert(text: "Name must be at least 5 characters.")
            self.present(alert, animated: true)
                
            return false
        }
        
        guard let phone = self.phoneTextField.text,
            phone.characters.count > 4 else {
                
                let alert = UIAlertController.simpleAlert(text: "Name must be at least 5 characters.")
                self.present(alert, animated: true)
                
                return false
        }
        
        return true
    }
    
    
    
    @IBAction func addButtonPressed(_ sender: Any) {
        
        guard self.checkFields() else { return }
        
        var parameters: [String: Any] = [:]
        parameters["name"] = self.nameTextField.text
        parameters["phone"] = self.phoneTextField.text
        
        let optionalUrl = URL(string: Constants.addUrl)
        
        guard let url = optionalUrl else { return }
        
        let request = Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default)
        request.responseJSON { (response) in
            
            if case .success(_) = response.result {
                
                debugPrint("Order added")
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}

extension AddViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        switch textField {
        case self.nameTextField:
            
            self.phoneTextField.becomeFirstResponder()
        default:
            break
        }
        
        return true
    }
}
