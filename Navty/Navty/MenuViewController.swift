//
//  MenuViewController.swift
//  Navty
//
//  Created by Thinley Dorjee on 3/1/17.
//  Copyright © 2017 Edward Anchundia. All rights reserved.
//

import UIKit
import SnapKit

class MenuViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        navigationController?.navigationBar.tintColor = ColorPalette.darkBlue
        
        viewHierarchy()
        constrainConfiguration()
        
    }

    
    func viewHierarchy(){
        
        view.addSubview(profilePicture)
        view.addSubview(labelOne)
        view.addSubview(labelTwo)
        view.addSubview(labelThree)
        view.addSubview(labelFour)
        
    }
    
    func constrainConfiguration(){
        
        self.edgesForExtendedLayout = []
        
        profilePicture.snp.makeConstraints { (photo) in
            photo.height.width.equalTo(60)
            photo.top.equalTo(view.snp.top).offset(30)
            photo.centerX.equalTo(view.snp.centerX)
        }
        
        labelOne.snp.makeConstraints { (label) in
            label.centerX.equalTo(view.snp.centerX)
            label.bottom.equalTo(profilePicture.snp.bottom).offset(40)
            label.height.equalTo(30)
            label.width.equalTo(view.snp.width).inset(20)
            
        }
        
        labelTwo.snp.makeConstraints { (label) in
            label.centerX.equalTo(view.snp.centerX)
            label.bottom.equalTo(labelOne.snp.bottom).offset(40)
            label.height.equalTo(30)
            label.width.equalTo(view.snp.width).inset(20)
        }
        
        labelThree.snp.makeConstraints { (label) in
            label.centerX.equalTo(view.snp.centerX)
            label.bottom.equalTo(labelTwo.snp.bottom).offset(40)
            label.height.equalTo(30)
            label.width.equalTo(view.snp.width).inset(20)
        }
        
        labelFour.snp.makeConstraints { (label) in
            label.centerX.equalTo(view.snp.centerX)
            label.bottom.equalTo(labelThree.snp.bottom).offset(40)
            label.height.equalTo(30)
            label.width.equalTo(view.snp.width).inset(20)
        }
    
        
    }
    
    internal lazy var profilePicture: UIImageView = {
        let photo = UIImageView()
        photo.image = #imageLiteral(resourceName: "iphone_default_image")
        photo.layer.cornerRadius = 30
        photo.layer.masksToBounds = true
        photo.contentMode = .scaleAspectFit
        return photo
    }()
    
    internal lazy var labelOne: UILabel = {
        let label = UILabel()
        label.text = "Code Word"
        label.textColor = .white
        label.textAlignment = .center
        label.layer.cornerRadius = 15
        label.layer.masksToBounds = true
        label.backgroundColor = ColorPalette.lightGreen
        return label
    }()
    
    internal lazy var labelTwo: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "Contact"
        label.textColor = .white
        label.layer.cornerRadius = 15
        label.layer.masksToBounds = true
        label.backgroundColor = ColorPalette.lightGreen
        return label
    }()
    
    internal lazy var labelThree: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "Community"
        label.textColor = .white
        label.layer.cornerRadius = 15
        label.layer.masksToBounds = true
        label.backgroundColor = ColorPalette.lightGreen
        return label
    }()
    
    internal lazy var labelFour: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "Profile"
        label.textColor = .white
        label.layer.cornerRadius = 15
        label.layer.masksToBounds = true
        label.backgroundColor = ColorPalette.lightGreen
        return label
    }()
   

}
