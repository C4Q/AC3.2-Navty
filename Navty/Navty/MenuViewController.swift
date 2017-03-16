//
//  MenuViewController.swift
//  Navty
//
//  Created by Thinley Dorjee on 3/1/17.
//  Copyright © 2017 Edward Anchundia. All rights reserved.
//

import UIKit
import SnapKit
import PubNub

class MenuViewController: UIViewController, UISplitViewControllerDelegate, PNObjectEventListener {

    var client: PubNub!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = ColorPalette.darkBlue
        navigationController?.isNavigationBarHidden = true
        
        viewHierarchy()
        constrainConfiguration()
        
        let configuration = PNConfiguration(publishKey: "pub-c-28163faf-5853-487e-8cc9-1d8f955ad129", subscribeKey: "sub-c-0ee17ac4-08cb-11e7-b95c-0619f8945a4f")
        self.client = PubNub.clientWithConfiguration(configuration)
        self.client.addListener(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.dismiss(animated: true, completion: nil)
        print("willdisappear")
        
       
    }
    
    func viewHierarchy(){
        view.addSubview(profilePicture)
        view.addSubview(codewordButton)
        view.addSubview(contactButton)
        view.addSubview(communityButton)
        view.addSubview(profileButton)
        view.addSubview(trackingButton)
        view.addSubview(switchLabel)
        view.addSubview(trackingSwitch)
    }
    
    func constrainConfiguration(){
        self.edgesForExtendedLayout = []
        
        profilePicture.snp.makeConstraints { (photo) in
            photo.height.width.equalTo(150)
            photo.top.equalTo(view.snp.top).offset(75)
            photo.centerX.equalTo(view.snp.centerX)
        }
        
        codewordButton.snp.makeConstraints { (button) in
            button.centerX.equalTo(view.snp.centerX)
//            button.bottom.equalTo(profilePicture.snp.bottom).offset(40)
            button.height.equalTo(30)
            button.width.equalTo(view.snp.width).inset(20)
            button.top.equalTo(profilePicture.snp.bottom).offset(20)
            
        }
        
        contactButton.snp.makeConstraints { (button) in
            button.centerX.equalTo(view.snp.centerX)
            //button.bottom.equalTo(profilePicture.snp.bottom).offset(40)
            button.height.equalTo(30)
            button.width.equalTo(view.snp.width).inset(20)
            button.top.equalTo(codewordButton.snp.bottom).offset(20)
        }

        communityButton.snp.makeConstraints { (button) in
            button.centerX.equalTo(view.snp.centerX)
            //button.bottom.equalTo(profilePicture.snp.bottom).offset(40)
            button.height.equalTo(30)
            button.width.equalTo(view.snp.width).inset(20)
            button.top.equalTo(contactButton.snp.bottom).offset(20)
        }

        profileButton.snp.makeConstraints { (button) in
            button.centerX.equalTo(view.snp.centerX)
            //button.bottom.equalTo(profilePicture.snp.bottom).offset(40)
            button.height.equalTo(30)
            button.width.equalTo(view.snp.width).inset(20)
            button.top.equalTo(communityButton.snp.bottom).offset(20)
        }
        
        trackingButton.snp.makeConstraints { (button) in
            button.centerX.equalTo(view.snp.centerX)
            //button.bottom.equalTo(profilePicture.snp.bottom).offset(40)
            button.height.equalTo(30)
            button.width.equalTo(view.snp.width).inset(20)
            button.top.equalTo(profileButton.snp.bottom).offset(20)
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
    
    func LoginController() {
        let LoginVC = LoginViewController()
        if let navVC = self.navigationController {
            navVC.pushViewController(LoginVC, animated: true)
        }
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
            
            if Settings.shared.navigationStarted == true {
                let alert = UIAlertController(title: "Channel Name", message: "Enter Channel:", preferredStyle: .alert)
                alert.addTextField(configurationHandler: { (textfield) in
                    textfield.placeholder = "Channel Here"
                })
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                    let textField = alert?.textFields![0]
                    Settings.shared.channelName = (textField?.text)!
                    print(Settings.shared.channelName)
                    self.client.subscribeToChannels([Settings.shared.channelName], withPresence: true)
                }))
                self.navigationController?.present(alert, animated: true, completion: nil)
            }
        } else {
            print("its off")
            switchLabel.text = "Tracking Disabled"
            Settings.shared.trackingEnabled = false
        }
    }
    
    
    internal lazy var profilePicture: UIImageView = {
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
        button.addTarget(self, action: #selector(LoginController), for: .touchUpInside)
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
