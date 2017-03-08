//
//  MessageComposer.swift
//  textMessage
//
//  Created by Thinley Dorjee on 3/7/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import Foundation
import MessageUI

let textMessageRecipients = [String]()

class MessageComposer: NSObject, MFMessageComposeViewControllerDelegate {

    func canSendText() -> Bool {
        return MFMessageComposeViewController.canSendText()
    }
    
    func configuredMessageComposeViewController() -> MFMessageComposeViewController {
        let messageComposeVC = MFMessageComposeViewController()
        messageComposeVC.messageComposeDelegate = self
        messageComposeVC.recipients = textMessageRecipients
        messageComposeVC.body =  "I arrieved home safely"
        return messageComposeVC
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
}
