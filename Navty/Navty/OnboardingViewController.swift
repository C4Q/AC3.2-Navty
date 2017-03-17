//
//  OnboardingViewController.swift
//  Navty
//
//  Created by Edward Anchundia on 3/17/17.
//  Copyright © 2017 Edward Anchundia. All rights reserved.
//

import UIKit
import SnapKit
import paper_onboarding                               

class OnboardingViewController: UIViewController, PaperOnboardingDataSource, PaperOnboardingDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        //view.backgroundColor = .white

        let onboarding = PaperOnboarding(itemsCount: 3)
        onboarding.dataSource = self
        onboarding.delegate = self
        onboarding.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(onboarding)
        
        for attribute: NSLayoutAttribute in [.left, .right, .top, .bottom] {
            let constraint = NSLayoutConstraint(item: onboarding,
                                                attribute: attribute,
                                                relatedBy: .equal,
                                                toItem: view,
                                                attribute: attribute,
                                                multiplier: 1,
                                                constant: 0)
            view.addConstraint(constraint)
        }
        
        view.addSubview(getStartedButton)
        
        getStartedButton.snp.makeConstraints({ (view) in
            view.bottom.equalTo(self.view.snp.bottom).inset(85)
            view.centerX.equalToSuperview()
            view.height.equalTo(50)
            view.width.equalTo(150)
        })
    }
    
    func onboardingItemsCount() -> Int {
        return 3
    }
    
    func onboardingItemAtIndex(_ index: Int) -> OnboardingItemInfo {
        let backgroundColorOne = ColorPalette.bgColor
        let backgroundColorTwo = ColorPalette.bgColor
        let backgroundColorThree = ColorPalette.bgColor
        
        let titleFont = UIFont(name: "AvenirNext-Bold", size: 24)!
        let descriptionFont = UIFont(name: "AvenirNext-Regular", size: 18)!
        
        return [("location_icon", "Would you take shortest or safest route?", "Where ever you go, Navty help you to keep you safe by connecting with your loved ones", "", backgroundColorOne, UIColor.white, UIColor.white, titleFont, descriptionFont),
                ("Search_icon", "Search Your Destination", "Search your destination by zip-code and choose the safest route to take", "", backgroundColorTwo, UIColor.white, UIColor.white, titleFont, descriptionFont),
                ("board_icon", "Get there safely", "Where ever you go, Navty help you to keep you safe by connecting with your loved ones", "", backgroundColorThree, UIColor.white, UIColor.white, titleFont, descriptionFont)][index]
    }
    
    func onboardingWillTransitonToIndex(_ index: Int) {
        if index == 1 {
            if self.getStartedButton.alpha == 1 {
                UIView.animate(withDuration: 0.2, animations: {
                    self.getStartedButton.alpha = 0
                })
            }
        }
    }
    
    func onboardingDidTransitonToIndex(_ index: Int) {
        if index == 2 {
            if self.getStartedButton.alpha == 0 {
                UIView.animate(withDuration: 0.2, animations: {
                    self.getStartedButton.alpha = 1
                })
            }
        }
    }
    
    func onboardingConfigurationItem(_ item: OnboardingContentViewItem, index: Int) {
//        if index == 2{
//            getStartedButton.snp.makeConstraints({ (view) in
//                view.top.equalTo((item.descriptionLabel?.snp.bottom)!).inset(20)
//                view.centerX.equalToSuperview()
//                view.height.equalTo(50)
//                view.width.equalTo(150)
//            })
//        }
    }
    
    func toMapVC(){
        
        let userDefaults = UserDefaults.standard
        userDefaults.set(true, forKey: "onboardingComplete")
        userDefaults.synchronize()
        
//        let navController = UINavigationController(rootViewController: NavigationMapViewController())
        let mapVC = NavigationMapViewController()
        self.navigationController?.pushViewController(mapVC, animated: true)
        
    }
    
    internal lazy var getStartedButton: UIButton = {
        let button = UIButton()
        button.setTitle("Get Started", for: .normal)
        button.alpha = 0
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.borderColor = UIColor(white: 1, alpha: 1).cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 15
        button.addTarget(self, action: #selector(toMapVC), for: .touchUpInside)
        return button
    }()

}
