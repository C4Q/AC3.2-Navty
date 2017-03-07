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
            view.width.equalTo(50)
            view.height.equalTo(contentView.snp.height).multipliedBy(0.95)
            view.centerY.equalTo(contentView.snp.centerY)
        })
        
        directionLabel.snp.makeConstraints({ (view) in
            view.leading.equalTo(directionPointerImage.snp.trailing).offset(10)
            view.trailing.equalTo(contentView.snp.trailing).inset(10)
            view.height.equalTo(contentView.snp.height)
        })
    }

}
