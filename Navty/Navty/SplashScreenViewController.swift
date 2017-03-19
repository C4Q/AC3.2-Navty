//
//  SplashScreenViewController.swift
//  Onboard
//
//  Created by Thinley Dorjee on 3/6/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import UIKit

class SplashScreenViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = ColorPalette.bgColor
        
        let iconWithAlpha = icon
        iconWithAlpha.alpha = 0.0
        view.addSubview(iconWithAlpha)
        
        iconWithAlpha.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        iconWithAlpha.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -30).isActive = true
        iconWithAlpha.heightAnchor.constraint(equalToConstant: 90).isActive = true
        iconWithAlpha.widthAnchor.constraint(equalToConstant: 90).isActive = true
        
        UIView.animate(withDuration: 2.0, delay: 0.0, options: .curveEaseInOut, animations: {
            self.icon.alpha = 1.0
        }, completion: nil)
        
        perform(#selector(SegueToOnboardVc), with: nil, afterDelay: 4)
        
        navigationController?.isNavigationBarHidden = true
        
    }
    
    func SegueToOnboardVc(){
        _ = UserDefaults.standard
        
//        if userdefaults.bool(forKey: "onboardingComplete") {
//            let navigationMapView = NavigationMapViewController()
//            navigationController?.pushViewController(navigationMapView, animated: true)
//        } else {
            let onboardVC = OnboardingViewController()
            navigationController?.pushViewController(onboardVC, animated: true)
        //}
    }
    
    internal lazy var icon: UIImageView = {
        let image = UIImageView()
        image.image = #imageLiteral(resourceName: "PointSevenNavtyIcon")
        image.contentMode = .scaleAspectFit
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
}
