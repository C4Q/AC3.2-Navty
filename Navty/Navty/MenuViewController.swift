//
//  MenuViewController.swift
//  Navty
//
//  Created by Thinley Dorjee on 3/1/17.
//  Copyright © 2017 Edward Anchundia. All rights reserved.
//

import UIKit
import SnapKit

class MenuViewController: UIViewController, UISplitViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = ColorPalette.darkBlue
        navigationController?.isNavigationBarHidden = true
        
        viewHierarchy()
        constrainConfiguration()    
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func viewHierarchy(){
        view.addSubview(profilePicture)
        //view.addSubview(codewordButton)
        view.addSubview(contactButton)
        //view.addSubview(communityButton)
        //view.addSubview(profileButton)
        view.addSubview(trackingButton)
        view.addSubview(switchLabel)
        view.addSubview(trackingSwitch)
        view.addSubview(panicButton)
    }
    
    func constrainConfiguration(){
        self.edgesForExtendedLayout = []
        
        profilePicture.snp.makeConstraints { (photo) in
            photo.height.width.equalTo(150)
            photo.top.equalTo(view.snp.top).offset(75)
            photo.centerX.equalTo(view.snp.centerX)
        }
        
//        codewordButton.snp.makeConstraints { (button) in
//            button.centerX.equalTo(view.snp.centerX)
////            button.bottom.equalTo(profilePicture.snp.bottom).offset(40)
//            button.height.equalTo(30)
//            button.width.equalTo(view.snp.width).inset(20)
//            button.top.equalTo(profilePicture.snp.bottom).offset(20)
//            
//        }
        
        contactButton.snp.makeConstraints { (button) in
            button.centerX.equalTo(view.snp.centerX)
            //button.bottom.equalTo(profilePicture.snp.bottom).offset(40)
            button.height.equalTo(30)
            button.width.equalTo(view.snp.width).inset(20)
            button.top.equalTo(profilePicture.snp.bottom).offset(20)
        }

//        communityButton.snp.makeConstraints { (button) in
//            button.centerX.equalTo(view.snp.centerX)
//            //button.bottom.equalTo(profilePicture.snp.bottom).offset(40)
//            button.height.equalTo(30)
//            button.width.equalTo(view.snp.width).inset(20)
//            button.top.equalTo(contactButton.snp.bottom).offset(20)
//        }

//        profileButton.snp.makeConstraints { (button) in
//            button.centerX.equalTo(view.snp.centerX)
//            //button.bottom.equalTo(profilePicture.snp.bottom).offset(40)
//            button.height.equalTo(30)
//            button.width.equalTo(view.snp.width).inset(20)
//            button.top.equalTo(communityButton.snp.bottom).offset(20)
//        }
        
        trackingButton.snp.makeConstraints { (button) in
            button.centerX.equalTo(view.snp.centerX)
            //button.bottom.equalTo(profilePicture.snp.bottom).offset(40)
            button.height.equalTo(30)
            button.width.equalTo(view.snp.width).inset(20)
            button.top.equalTo(contactButton.snp.bottom).offset(20)
        }
        panicButton.snp.makeConstraints { (button) in
            button.top.equalTo(trackingButton.snp.bottom).offset(75)
            button.height.width.equalTo(75)
            button.centerX.equalToSuperview()
        }
        switchLabel.snp.makeConstraints({ (view) in
            view.leading.equalToSuperview().inset(20)
            view.bottom.equalToSuperview().inset(15)
            view.height.equalTo(25)
            view.width.equalTo(150)
        })
        
        trackingSwitch.snp.makeConstraints({ (view) in
            view.bottom.equalToSuperview().inset(15)
            view.leading.equalTo(switchLabel.snp.trailing).offset(15)
        })
    }
    
    func contactsController() {
        let ContactsTC = ContactsTableViewController()
        if let navVC = self.navigationController {
            navVC.pushViewController(ContactsTC, animated: true)
        }
    }
    
//    func LoginController() {
//        let LoginVC = LoginViewController()
//        if let navVC = self.navigationController {
//            navVC.pushViewController(LoginVC, animated: true)
//        }
//    }
    
    func callButton(_ sender: UIButton) {
        let url = NSURL(string: "tel://911")!
        UIApplication.shared.openURL(url as URL)
        print("calling")
    }
    
    func trackingController() {
        dismiss(animated: true, completion: nil)
        let trackingVC = TrackingViewController()
        if let navVC = self.navigationController {
            navVC.pushViewController(trackingVC, animated: true)
        }
    }
    
    func switchValueChanged(sender: UISwitch) {
        if sender.isOn == true {
            print("its on")
            switchLabel.text = "Tracking Enabled"
            Settings.shared.trackingEnabled = true
        } else {
            print("its off")
            switchLabel.text = "Tracking Disabled"
            Settings.shared.trackingEnabled = false
        }
    }
    
    
    internal var profilePicture: UIImageView = {
        let photo = UIImageView()
        photo.image = UIImage(named: "newIcon")
        //photo.layer.cornerRadius = 30
        photo.layer.masksToBounds = true
        photo.contentMode = .scaleAspectFit
        return photo
    }()
    
    internal var codewordButton: UIButton = {
        let button = UIButton(type: .custom)
        //button.backgroundColor = ColorPalette.lightGreen
        button.setTitle("Codeword", for: .normal)
        button.titleLabel?.textAlignment = .right
        button.alpha = 0.8
        button.layer.masksToBounds = true
        //button.addTarget(self, action: #selector(buttonAction), forControlEvents: .TouchUpInside)
        return button
    }()
    
    
    internal var contactButton: UIButton = {
        let button = UIButton(type: .custom)
        //button.backgroundColor = ColorPalette.lightGreen
        button.setTitle("Contact", for: .normal)
        button.alpha = 0.8
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(contactsController), for: .touchUpInside)
        return button
    }()
    
    internal var communityButton: UIButton = {
        let button = UIButton(type: .custom)
        //button.backgroundColor = ColorPalette.lightGreen
        button.setTitle("Community", for: .normal)
        button.alpha = 0.8
        button.layer.masksToBounds = true
        //button.addTarget(self, action: #selector(buttonAction), forControlEvents: .TouchUpInside)
        return button
    }()
    
    internal var profileButton: UIButton = {
        let button = UIButton(type: .custom)
        //button.backgroundColor = ColorPalette.lightGreen
        button.setTitle("Profile", for: .normal)
        button.alpha = 0.8
        button.layer.masksToBounds = true
        //button.addTarget(self, action: #selector(LoginController), for: .touchUpInside)
        return button
    }()
    
    internal var panicButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = ColorPalette.red
        button.setTitle("PANIC", for: .normal)
        button.layer.cornerRadius = 37.5
        button.alpha = 0.8
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(callButton(_:)), for: .touchUpInside)
        return button
    }()
   
    internal var trackingButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Tracking", for: .normal)
        button.alpha = 0.8
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(trackingController), for: .touchUpInside)
        return button
    }()
    
    internal var switchLabel: UILabel = {
        let label = UILabel()
        label.text = "Tracking Disabled"
        label.textColor = .white
        return label
    }()
    
    internal var trackingSwitch: UISwitch = {
        let trackingSwitch = UISwitch()
        trackingSwitch.addTarget(self, action: #selector(switchValueChanged(sender:)), for: .valueChanged)
        return trackingSwitch
    }()
}
