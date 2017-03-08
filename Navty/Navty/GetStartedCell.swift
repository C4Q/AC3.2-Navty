//
//  GetStartedCell.swift
//  Onboard
//
//  Created by Thinley Dorjee on 3/5/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import UIKit

protocol PushingViewController {
    func pushViewController(viewController: UIViewController)
}

class GetStartedCell: UICollectionViewCell {
    
    var pushingViewController: PushingViewController!
    
    override init(frame: CGRect){
        super.init(frame: frame)
        
        backgroundColor = ColorPalette.bgColor
        
        addSubview(startButton)
        
        startButton.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        startButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        startButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        startButton.widthAnchor.constraint(equalToConstant: 120).isActive = true
    }
    
    internal lazy var startButton: UIButton = {
       let button = UIButton()
        button.setTitle("Get Started", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.borderColor = UIColor(white: 1, alpha: 1).cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 15
        button.addTarget(self, action: #selector(toMapVC), for: .touchUpInside)
        return button
    }()
    
    func toMapVC(){
    
        let navController = UINavigationController(rootViewController: NavigationMapViewController())
        self.pushingViewController.pushViewController(viewController: navController)

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
