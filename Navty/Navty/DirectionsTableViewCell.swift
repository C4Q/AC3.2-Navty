//
//  DirectionsTableViewCell.swift
//  Navty
//
//  Created by Edward Anchundia on 3/6/17.
//  Copyright © 2017 Edward Anchundia. All rights reserved.
//

import UIKit

class DirectionsTableViewCell: UITableViewCell {
    
    var directionPointerImage = UIImageView()
    var directionLabel = UILabel()
    var directionTimeLabel = UILabel()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.addSubview(directionPointerImage)
        self.contentView.addSubview(directionLabel)
        self.contentView.addSubview(directionTimeLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        directionPointerImage.snp.makeConstraints({ (view) in
            view.leading.equalTo(contentView.snp.leading)
            view.width.equalTo(150)
            view.height.equalTo(contentView.snp.height).multipliedBy(0.95)
            //view.centerX.equalTo(contentView.snp.centerX)
        })
        
        directionLabel.snp.makeConstraints({ (view) in
            view.leading.equalTo(directionPointerImage.snp.trailing).inset(20)
        })
    }

}
