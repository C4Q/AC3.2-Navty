//
//  LoginViewController .swift
//  Navty
//
//  Created by Miti Shah on 3/8/17.
//  Copyright © 2017 Edward Anchundia. All rights reserved.
//

import UIKit
import SnapKit
import Firebase
import FirebaseAuth

class LoginViewController: UIViewController, UITextFieldDelegate {
    // a lot of this code is based on code from the recent mid-unit assessment
    
    let databaseReference = FIRDatabase.database().reference().child("Users")
    var databaseObserver:FIRDatabaseHandle?
    var signInUser: FIRUser?
    var users = [Users]()
    
    var propertyAnimator: UIViewPropertyAnimator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        self.navigationItem.title = "LOGIN/REGISTER"
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        setupViewHierarchy()
        
        self.navigationController?.isToolbarHidden = false
        self.navigationController?.isNavigationBarHidden = false
        
        let loginVC = LoginViewController()
        if FIRAuth.auth()?.currentUser != nil {
            //            FIRAuth.auth()?.currentUser?.uid.
            self.navigationController?.pushViewController(loginVC, animated: true)
            
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case emailTextField:
            emailTextField.resignFirstResponder()
        case passwordTextField:
            passwordTextField.resignFirstResponder()
        default:
            break
        }
        return true
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.propertyAnimator = UIViewPropertyAnimator(duration: 3.0, dampingRatio: 0.75, animations: nil)
        
        configureConstraints()
        resetButtonColors()
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        _ = [profilePictureImageView, emailLineView, passwordLineView, passwordTextField, emailTextField, loginButton, registerButton].map{ $0.isHidden = false }
        
        self.startSlidingAnimations()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        resetButtonColors()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.resetViews()
        self.removeBehaviors()
        self.removeConstraints()
    }
    
    // MARK: - Tear Down
    
    internal func removeBehaviors() {
        self.propertyAnimator = nil
    }
    
    internal func resetViews() {
        _ = [profilePictureImageView, emailLineView, passwordLineView, passwordTextField, emailTextField, loginButton, registerButton].map{ $0.isHidden = true }
    }
    
    private func removeConstraints() {
        _ = [profilePictureImageView, emailLineView, passwordLineView, passwordTextField, emailTextField, loginButton, registerButton].map { $0.snp.removeConstraints() }
    }
    
    func setupViewHierarchy() {
        self.edgesForExtendedLayout = []
        
        self.view.addSubview(cover)
        self.view.addSubview(profilePictureImageView)
        self.view.addSubview(emailTextField)
        self.view.addSubview(emailLineView)
        self.view.addSubview(passwordTextField)
        self.view.addSubview(passwordLineView)
        self.view.addSubview(loginButton)
        self.view.addSubview(registerButton)
        
        loginButton.addTarget(self, action: #selector(didTapLogin(sender:)) , for: .touchUpInside)
        registerButton.addTarget(self, action: #selector(registeredPressed(sender:)), for: .touchUpInside)
    }
    
    func configureConstraints() {
        cover.snp.makeConstraints{ (view) in
            view.width.equalToSuperview()
            view.top.equalToSuperview()
            view.bottom.equalToSuperview()
        }
        
        profilePictureImageView.snp.makeConstraints { (view) in
            view.centerX.equalToSuperview()
            view.top.equalTo(cover.snp.top).offset(20)
        }
        
        emailTextField.snp.makeConstraints { (view) in
            view.centerX.equalToSuperview()
            view.width.equalToSuperview().multipliedBy(0.8)
            view.top.equalTo(profilePictureImageView.snp.bottom).offset(40)
        }
        
        emailLineView.snp.makeConstraints { (view) in
            view.leading.trailing.equalTo(emailTextField)
            view.top.equalTo(emailTextField.snp.bottom)
            view.height.equalTo(1)
        }
        
        passwordTextField.snp.makeConstraints { (view) in
            view.centerX.equalToSuperview()
            view.width.equalToSuperview().multipliedBy(0.8)
            view.top.equalTo(emailTextField.snp.bottom).offset(30)
        }
        
        passwordLineView.snp.makeConstraints { (view) in
            view.leading.trailing.equalTo(passwordTextField)
            view.top.equalTo(passwordTextField.snp.bottom)
            view.height.equalTo(1)
        }
        
        registerButton.snp.makeConstraints { (view) in
            view.centerX.equalToSuperview()
            view.bottom.equalTo(bottomLayoutGuide.snp.top).offset(-25)
            view.leading.equalToSuperview().offset(70)
            view.trailing.equalToSuperview().inset(70)
            view.height.equalTo(50)
        }
        
        loginButton.snp.makeConstraints { (view) in
            view.centerX.equalToSuperview()
            view.bottom.equalTo(registerButton.snp.top).inset(-10)
            view.width.equalTo(registerButton)
            view.height.equalTo(registerButton)
        }
    }
    
    //MARK: - FireBase
    
    private func loginAnonymously() {
        FIRAuth.auth()?.signInAnonymously(completion: { (user: FIRUser? , error: Error? ) in
            
            print("signed in anonymously")
            if error != nil {
                print("Error: \(error)")
            }
            
            if user != nil {
                print("signed in anonymously!")
                self.signInUser = user
            }
        })
        
    }
    
    // MARK: - Actions
    
    func didTapLogin(sender: UIButton) {
        sender.backgroundColor = ColorPalette.bgColor
        sender.setTitleColor(ColorPalette.bgColor, for: .normal)
        
        if let email = emailTextField.text,
            let password = passwordTextField.text {
            FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user: FIRUser?, error: Error?) in
                
                
                if user != nil {
                    let newViewController = LoginViewController()
                    if let tabVC =  self.navigationController {
                        tabVC.show(newViewController, sender: nil)
                    }
                } else {
                    self.resetButtonColors()
                }
            })
        }
    }
    
    func registeredPressed(sender: UIButton) {
        sender.backgroundColor = ColorPalette.bgColor
        sender.setTitleColor(ColorPalette.bgColor, for: .normal)
 
        
        if let email = emailTextField.text,
            let password = passwordTextField.text {
            FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user: FIRUser?, error: Error?) in
                if error != nil {
                    //print (error)
                    return
                }
                guard let uid = user?.uid else {return}
                let values = ["email": email]
                
                self.registerUserIntoDatabaseWithUID(uid: uid, values: values)
                
            })
        }
    }
    
    private func registerUserIntoDatabaseWithUID(uid: String, values: [String: Any]) {
        
        let userReference = self.databaseReference.child(uid)
        userReference.updateChildValues(values)
        
        let newViewController = LoginViewController()
        if let tabVC =  self.navigationController {
            tabVC.show(newViewController, sender: nil)
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        resetButtonColors()
    }
    
    
    func resetButtonColors() {
        loginButton.backgroundColor = ColorPalette.bgColor
        loginButton.setTitleColor(ColorPalette.lightGreen, for: .normal)
        
        registerButton.backgroundColor = ColorPalette.bgColor
        registerButton.setTitleColor(ColorPalette.lightGreen, for: .normal)
    }
    
    
    // MARK: - Animations
    
    internal func addSlidingAnimationToLogo() {
        propertyAnimator?.addAnimations {
            self.view.layoutIfNeeded()
        }
        
        cover.snp.remakeConstraints{ (view) in
            view.top.equalTo(topLayoutGuide.snp.top).offset(40)
            view.bottom.equalTo(profilePictureImageView.snp.bottom).offset(20)
            view.leading.equalTo(profilePictureImageView.snp.leading).offset(-20)
            view.trailing.equalTo(profilePictureImageView.snp.trailing).offset(20)
           
        }
    }
    
    internal func startSlidingAnimations() {
        // 1. Begin the animations
        addSlidingAnimationToLogo()
        propertyAnimator?.startAnimation()
    }
    
    //MARK: -Lazy Properties
    
    lazy var cover: UIView = {
        let view = UIView()
        view.backgroundColor = ColorPalette.lightGreen
        view.layer.cornerRadius = 50
        return view
    }()
    
    lazy var profilePictureImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "newIcon")
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 5)
        view.layer.shadowRadius = 5
        return view
    }()
    
    lazy var emailTextField: UITextField = {
        let view = UITextField()
        view.text = "Email"
        view.textAlignment = .left
        view.textColor = ColorPalette.darkBlue
        view.clipsToBounds = false
        return view
    }()
    
    internal lazy var emailLineView: UIView = {
        let view: UIView = UIView()
        view.backgroundColor = ColorPalette.darkBlue
        return view
    }()
    
    lazy var passwordTextField: UITextField = {
        let view = UITextField()
        view.text = "Password"
        view.textColor = ColorPalette.darkBlue
        view.textAlignment = .left
        return view
    }()
    
    internal lazy var passwordLineView: UIView = {
        let view: UIView = UIView()
        view.backgroundColor = ColorPalette.darkBlue
        
        return view
    }()
    
    lazy var loginButton: UIButton = {
        let button: UIButton = UIButton(type: .roundedRect)
        button.setTitle("LOGIN", for: .normal)
        button.setTitleColor(ColorPalette.lightGreen, for: .normal)
        button.backgroundColor = .clear
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16.0, weight: UIFontWeightSemibold)
        button.layer.borderWidth = 2.0
        button.layer.borderColor = ColorPalette.lightGreen.cgColor
        button.contentEdgeInsets = UIEdgeInsetsMake(15.0, 0.0, 15.0, 0.0)
        button.alpha = 0.6
        return button
    }()
    
    lazy var registerButton: UIButton = {
        let button: UIButton = UIButton(type: .roundedRect)
        button.setTitle("REGISTER", for: .normal)
        button.setTitleColor(ColorPalette.lightGreen, for: .normal)
        button.backgroundColor = .clear
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16.0, weight: UIFontWeightSemibold)
        button.layer.borderWidth = 2.0
        button.layer.borderColor = ColorPalette.lightGreen.cgColor
        button.contentEdgeInsets = UIEdgeInsetsMake(15.0, 0.0, 15.0, 0.0)
        button.alpha = 0.6
        return button
    }()
}

