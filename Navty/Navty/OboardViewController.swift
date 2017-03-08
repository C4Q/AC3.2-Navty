//
//  ViewController.swift
//  Onboard
//
//  Created by Thinley Dorjee on 3/3/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import UIKit

class OnboardViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, PushingViewController{

    let pages: [Pages] = {
        
        let firstPage = Pages(image: "location_icon", title: "Would you take shortest or safest route? ", description: "Where ever you go, Navty help you to keep you safe by connecting with your loved ones")
        let secondPage = Pages(image: "Search_icon", title: "Search Your Destination", description: "Search your destination by zip-code and choose the safest route to take")
        let thirdPage = Pages(image: "board_icon", title: "Get there safely", description: "Where ever you go, Navty help you to keep you safe by connecting with your loved ones")
        
        return [firstPage, secondPage, thirdPage]
        
    }()

    let cellId = "cellId"
    let GetStartedCellId = "GetStartedCell"
    
    var pageControllerBottom: NSLayoutConstraint?
    var skipButtonTopAnchor: NSLayoutConstraint?
    var backButtonTopAnchor: NSLayoutConstraint?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.statusBarStyle = .lightContent
        
        collectionView.backgroundColor = ColorPalette.bgColor
    
        view.addSubview(collectionView)
        view.addSubview(pageController)
        view.addSubview(backButton)
        view.addSubview(skipButton)
        
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
 
        pageController.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        pageController.heightAnchor.constraint(equalToConstant: 30).isActive = true
        pageControllerBottom = pageController.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20)
        pageControllerBottom?.isActive = true
        
        backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        backButtonTopAnchor = backButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 16)
        backButtonTopAnchor?.isActive = true
      
       skipButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
       skipButtonTopAnchor = skipButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 16)
        skipButtonTopAnchor?.isActive = true
       
        registerCell()
    }
    
    private func registerCell(){
        
        collectionView.register(OnboardCollectionViewCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.register(GetStartedCell.self, forCellWithReuseIdentifier: GetStartedCellId)
        
    }
    
    //MARK: Scroll Views
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let pageNumber = Int(targetContentOffset.pointee.x / view.frame.width)
        pageController.currentPage = pageNumber
        
        if pageNumber == pages.count{

            topAnimation()
    
        }else {
            pageControllerBottom?.constant = -20
            backButtonTopAnchor?.constant = 16
            skipButtonTopAnchor?.constant = 16
         
        }
        
        if pageNumber == 0 {
            self.backButton.isHidden = true
        }else{
            self.backButton.isHidden = false
        }
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: { 
            self.view.layoutIfNeeded()
        }, completion: nil)
      
    }
    
    //MARK: Collection
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pages.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       
        if indexPath.item == pages.count {
            let privacyCell = collectionView.dequeueReusableCell(withReuseIdentifier: self.GetStartedCellId, for: indexPath) as! GetStartedCell
            privacyCell.pushingViewController = self
            return privacyCell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! OnboardCollectionViewCell
        
        let page = pages[indexPath.item]
     
        cell.page = page
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.height)
    }
    
    //MARK: - PushingViewController Delegate Method
    func pushViewController(viewController: UIViewController) {
        self.present(viewController, animated: true, completion: nil)
        //self?.pushViewController(viewController, animated: true)
    }
    
    //MARK: Actions
    func topAnimation(){
        pageControllerBottom?.constant = 40
        backButtonTopAnchor?.constant = -32
        skipButtonTopAnchor?.constant = -32
        
    }
    
    
    func previousPage(){
        
        if pageController.currentPage == 0{
            return
        }
        
        let indexPath = IndexPath(item: pageController.currentPage - 1, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        pageController.currentPage -= 1
        
    }
    
    
    
    func skip(){
        
        pageController.currentPage = pages.count - 1
        
        if pageController.currentPage == pages.count{
            return
        }
        
        topAnimation()
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
        
        
        let indexPath = IndexPath(item: pageController.currentPage + 1, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        pageController.currentPage += 1
    }
    
    //MARK: Outlets
    
    //BackButton
    
    internal lazy var backButton: UIButton = {
        let button = UIButton()
        button.setTitle("Back", for: .normal)
        button.tintColor = .white
        button.isHidden = true
        button.addTarget(self, action: #selector(previousPage), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    
    //Skip button
    
    internal lazy var skipButton: UIButton = {
        let button = UIButton()
        button.setTitle("Skip", for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(skip), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    //Collection View
    internal lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        let collectionVC = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionVC.delegate = self
        collectionVC.dataSource = self
        collectionVC.isPagingEnabled = true
        
        collectionVC.translatesAutoresizingMaskIntoConstraints = false
        
        return collectionVC
    }()
    
    //Page controller
    internal lazy var pageController: UIPageControl = {
        let pageController = UIPageControl()
        pageController.pageIndicatorTintColor = .lightGray
        pageController.currentPageIndicatorTintColor = UIColor(red: 106/255, green: 185/255, blue: 212/255, alpha: 1)
        pageController.numberOfPages = self.pages.count + 1
        pageController.translatesAutoresizingMaskIntoConstraints = false
        return pageController
    }()



}

