//
//  ViewController.swift
//  Demo-FaceID
//
//  Created by User on 14.07.2021.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupVC()
    }

    private func setupVC() {
        emailTextField.delegate = self
        passwordTextField.delegate = self

        loginButton.layer.cornerRadius = 5
        emailTextField.layer.cornerRadius = 5
        passwordTextField.layer.cornerRadius = 5
        
        emailTextField.attributedPlaceholder = NSAttributedString(string: "Email",
                                                                  attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "Password",
                                                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])

        emailTextField.layer.borderWidth = 2
        passwordTextField.layer.borderWidth = 2
        loginButton.layer.borderWidth = 2

        emailTextField.layer.borderColor = UIColor.darkGray.cgColor
        passwordTextField.layer.borderColor = UIColor.darkGray.cgColor
        loginButton.layer.borderColor = UIColor.darkGray.cgColor

    }

    @IBAction func didTapLoginButton(_ sender: Any) {

    }

}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
