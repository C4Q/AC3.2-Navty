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

        view.backgroundColor = .white
        navigationController?.navigationBar.tintColor = ColorPalette.darkBlue
        
        navigationController?.isNavigationBarHidden = true
        
        viewHierarchy()
        constrainConfiguration()    
    }

    
    func viewHierarchy(){
        
        view.addSubview(profilePicture)
        view.addSubview(codewordButton)
        view.addSubview(contactButton)
        view.addSubview(communityButton)
        view.addSubview(profileButton)
        
    }
    
    func constrainConfiguration(){
        
        self.edgesForExtendedLayout = []
        
        profilePicture.snp.makeConstraints { (photo) in
            photo.height.width.equalTo(60)
            photo.top.equalTo(view.snp.top).offset(30)
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
    }
    
    func contactsController() {
        let ContactsTC = ContactsTableViewController()
        if let navVC = self.navigationController {
            navVC.pushViewController(ContactsTC, animated: true)
        }
    }
    
    internal lazy var profilePicture: UIImageView = {
        let photo = UIImageView()
        photo.image = #imageLiteral(resourceName: "Cycling Road Filled-50")
        photo.layer.cornerRadius = 30
        photo.layer.masksToBounds = true
        photo.contentMode = .scaleAspectFit
        return photo
    }()
    
    internal var codewordButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = ColorPalette.lightGreen
        button.setTitle("Codeword", for: .normal)
        button.alpha = 0.8
        button.layer.masksToBounds = true
        //button.addTarget(self, action: #selector(buttonAction), forControlEvents: .TouchUpInside)
        return button
    }()
    
    
    internal var contactButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = ColorPalette.lightGreen
        button.setTitle("Contact", for: .normal)
        button.alpha = 0.8
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(contactsController), for: .touchUpInside)
        return button
    }()
    
    internal var communityButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = ColorPalette.lightGreen
        button.setTitle("Community", for: .normal)
        button.alpha = 0.8
        button.layer.masksToBounds = true
        //button.addTarget(self, action: #selector(buttonAction), forControlEvents: .TouchUpInside)
        return button
    }()
    
    internal var profileButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = ColorPalette.lightGreen
        button.setTitle("Profile", for: .normal)
        button.alpha = 0.8
        button.layer.masksToBounds = true
        //button.addTarget(self, action: #selector(buttonAction), forControlEvents: .TouchUpInside)
        return button
    }()
   

}
