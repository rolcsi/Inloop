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
    @IBOutlet weak var addButton: UIButton!

    static let addButtonOffset: CGFloat = 50.0

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Add New Contact"

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(AddViewController.keyboardWillShow),
                                               name: NSNotification.Name.UIKeyboardWillShow,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(AddViewController.keyboardWillHide),
                                               name: NSNotification.Name.UIKeyboardWillHide,
                                               object: nil)

        let tap = UITapGestureRecognizer(target: self, action: #selector(AddViewController.handleTap(_:)))
        self.view.addGestureRecognizer(tap)
    }

    deinit {

        NotificationCenter.default.removeObserver(self)
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

    private func allowEditing(bool: Bool) {

        self.nameTextField.isUserInteractionEnabled = bool
        self.phoneTextField.isUserInteractionEnabled = bool
        self.addButton.isUserInteractionEnabled = bool
    }

    @IBAction func addButtonPressed(_ sender: Any) {

        guard self.checkFields() else { return }

        self.allowEditing(bool: false)

        var parameters: [String: Any] = [:]
        parameters["name"] = self.nameTextField.text
        parameters["phone"] = self.phoneTextField.text

        let optionalUrl = URL(string: Constants.addUrl)

        guard let url = optionalUrl else {

            self.allowEditing(bool: true)
            return
        }

        let request = Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default)
        request.responseJSON { (response) in

            self.allowEditing(bool: true)

            if case .success(_) = response.result {

                self.navigationController?.popViewController(animated: true)
            }
        }
    }

    @objc private func handleTap(_ sender: UITapGestureRecognizer) {

        self.nameTextField.resignFirstResponder()
        self.phoneTextField.resignFirstResponder()
    }

    @objc private func keyboardWillShow(notification: NSNotification) {

        guard let userInfo = notification.userInfo,
            var keyboardFrame: CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
            else { return }

        keyboardFrame = self.view.convert(keyboardFrame, from: nil)

        var contentInset: UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        scrollView.contentInset = contentInset
    }

    @objc private func keyboardWillHide(notification: NSNotification) {

        let contentInset: UIEdgeInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
    }
}

extension AddViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        switch textField {
        case self.nameTextField:

            self.phoneTextField.becomeFirstResponder()
        case self.phoneTextField:

            self.addButtonPressed(textField)
        default:
            break
        }

        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {

        if textField == self.phoneTextField {

            var frame = self.phoneTextField.frame
            frame.size.height += AddViewController.addButtonOffset
            self.scrollView.scrollRectToVisible(frame, animated: true)
        } else {

            self.scrollView.scrollRectToVisible(self.nameTextField.frame, animated: true)
        }
    }
}
