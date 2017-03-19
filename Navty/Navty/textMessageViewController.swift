
//
//  textMessageViewController.swift
//  textMessage
//
//  Created by Thinley Dorjee on 3/7/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import UIKit

class textMessageViewController: UIViewController {

    let messageComposer = MessageComposer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        navigationController?.isNavigationBarHidden = false
        
        //self.navigationController!.navigationBar.isTranslucent = false
        
        view.addSubview(sendMessage)
        
        sendMessage.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        sendMessage.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        sendMessage.heightAnchor.constraint(equalToConstant: 40).isActive = true
        sendMessage.widthAnchor.constraint(equalToConstant: 160).isActive = true
        
        navigationController?.navigationBar.tintColor = ColorPalette.bgColor
    }
    
    func sendMess(){
        if (messageComposer.canSendText()) {
            
            let messageComposeVC = messageComposer.configuredMessageComposeViewController()
            present(messageComposeVC, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Cannot Send Text Message", message: "Your device is not able to send text messages.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default) { (UIAlertAction) -> Void in }
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    internal lazy var sendMessage: UIButton = {
       let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Send Message", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 15
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(white: 0.2, alpha: 1).cgColor
        button.addTarget(self, action: #selector(sendMess), for: .touchUpInside)
        return button
    }()



}

