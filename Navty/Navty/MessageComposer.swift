//
//  MessageComposer.swift
//  textMessage
//
//  Created by Thinley Dorjee on 3/7/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import Foundation
import MessageUI
import Contacts

let textMessageRecipients = [String]()
let contactList = ContactsTableViewController()

class MessageComposer: NSObject, MFMessageComposeViewControllerDelegate {

    let userDefaults = UserDefaults.standard
    var userIdentifier = [String]()
    var contacts = [CNContact]()
    var contactPhoneNumberString = [String]()
    
    func canSendText() -> Bool {
        return MFMessageComposeViewController.canSendText()
    }
    
    func configuredMessageComposeViewController() -> MFMessageComposeViewController {
        let messageComposeVC = MFMessageComposeViewController()
        messageComposeVC.messageComposeDelegate = self
        let arrOfIdentifiers = userDefaults.object(forKey: "identifierArr") as? Array<String>
        contacts.removeAll()
        contactPhoneNumberString.removeAll()
        
        for contact in userDefaults.dictionaryRepresentation()  {
            if let array = arrOfIdentifiers{
                userIdentifier = array
                for identifier in userIdentifier {
                    if contact.key == identifier {
                        let unarchived = NSKeyedUnarchiver.unarchiveObject(with: contact.value as! Data) as? CNContact
                        contacts.append(unarchived!)
                    }
                }
            }
        }
        
        for x in 0..<contacts.count {
            for num in contacts[x].phoneNumbers {
                contactPhoneNumberString.append(num.value.stringValue)
            }
        }
        
        messageComposeVC.recipients = contactPhoneNumberString
        messageComposeVC.body =  "I arrived home safely"
        return messageComposeVC
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
}
