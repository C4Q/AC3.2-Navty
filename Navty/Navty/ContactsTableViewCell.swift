//
//  ContactsTableViewCell.swift
//  Navty
//
//  Created by Miti Shah on 3/3/17.
//  Copyright © 2017 Edward Anchundia. All rights reserved.
//


import UIKit
import SnapKit

class ContactTableViewCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        setUpViewHierarchy()
        makeConstraints()
        
    }
    
    func setUpViewHierarchy() {
        self.addSubview(nameLabel)
        self.addSubview(phoneLabel)
        
    }
    
    func makeConstraints() {
        nameLabel.snp.makeConstraints { (label) in
            label.top.equalToSuperview().offset(20)
            label.leading.equalToSuperview().inset(5)
        }
        
        phoneLabel.snp.makeConstraints { (label) in
            label.top.equalToSuperview().offset(20)
            label.trailing.equalToSuperview().inset(30)
        }
        
    }
    
    
    internal lazy var nameLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    internal lazy var phoneLabel: UILabel = {
        let label = UILabel()
        return label
    }()
}
