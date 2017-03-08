//
//  OnboardCollectionViewCell.swift
//  Onboard
//
//  Created by Thinley Dorjee on 3/3/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import UIKit

class OnboardCollectionViewCell: UICollectionViewCell {

    var page: Pages? {
        
        didSet{
            guard let page = page else { return }
            
            imageView.image = UIImage(named: page.image)
            
            let color = UIColor(white: 0.2, alpha: 1)
            let attributedText = NSMutableAttributedString(string: page.title, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 18, weight: UIFontWeightMedium), NSForegroundColorAttributeName: color])
            
            attributedText.append(NSAttributedString(string: "\n\n\(page.description)", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14, weight: UIFontWeightMedium), NSForegroundColorAttributeName: color]))
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            let length = attributedText.string.characters.count
            attributedText.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSRange(location: 0, length: length))
            
            textView.attributedText = attributedText
      
        }
    }
    
    override init(frame: CGRect){
        super.init(frame: frame)
    
        setupView()
    }
    
    func setupView(){
        
        backgroundColor = UIColor(red: 106/255, green: 185/255, blue: 212/255, alpha: 1)
        addSubview(imageView)
        addSubview(textView)
        
       imageView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -100).isActive = true
       imageView.heightAnchor.constraint(equalToConstant: 90).isActive = true
       imageView.widthAnchor.constraint(equalToConstant: 90).isActive = true
       
        textView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16).isActive = true
        textView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -16).isActive = true
        textView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.3).isActive = true
        textView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16).isActive = true
       
    }
    
    //image
    internal lazy var imageView: UIImageView = {
       let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.clipsToBounds = true
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    //textview
    internal lazy var textView: UITextView = {
        let text = UITextView()
        text.isEditable = false
        text.layer.cornerRadius = 15
        text.contentInset = UIEdgeInsets(top: 24, left: 0, bottom: 0, right: 0)
        text.translatesAutoresizingMaskIntoConstraints = false
        return text
    }()
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
