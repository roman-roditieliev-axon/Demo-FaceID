//
//  ViewController.swift
//  Demo-FaceID
//
//  Created by User on 14.07.2021.
//

import UIKit

// @Published var username = "a_podcast_admin@axon.dev"
//@Published var password = "Qwerty1234567"

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!

    private let segueMainIdentifier = "Main"
    private var networkManager = NetworkManager()
    private var storage = Storage()
    private var biometric = BiometricAuthManager()

    private var email = ""
    private var password = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        setupVC()

        if !storage.isFirstLaunch {
            checkFaceID()
        }
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

        loginButton.isUserInteractionEnabled = self.storage.isFirstLaunch ? true : false
    }

    private func login() {
        if !email.isEmpty && !password.isEmpty {
            networkManager.login(email: email, password: password, completion: { response in
                self.storage.isFirstLaunch = false
                self.checkFaceID()
            })
        }
    }

    private func checkFaceID() {
        biometric.authenticateUser { (str) in
            self.goToMainVC()
        }
    }

    private func goToMainVC() {
        performSegue(withIdentifier: segueMainIdentifier, sender: nil)
    }

    @IBAction func didTapLoginButton(_ sender: Any) {
        self.view.endEditing(true)
        login()
    }

}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField.text {
            switch textField {
            case emailTextField:
                self.email = text
            case passwordTextField:
                self.password = text
            default:
                break
            }
        }
    }
}
