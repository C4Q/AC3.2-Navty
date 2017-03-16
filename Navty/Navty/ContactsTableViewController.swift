//
//  ContactsTableViewController.swift
//  Navty
//
//  Created by Miti Shah on 3/2/17.
//  Copyright © 2017 Edward Anchundia. All rights reserved.
//
import UIKit
import Contacts
import ContactsUI
import DZNEmptyDataSet

class ContactsTableViewController: UITableViewController, CNContactPickerDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    var contactStore = CNContactStore()
    var contacts = [CNContact]()
    var userDefaults = UserDefaults.standard
    var userIdentifier = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(ContactTableViewCell.self, forCellReuseIdentifier: "Cell")
        
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        self.tableView.tableFooterView = UIView()
        self.navigationController?.isNavigationBarHidden = false
        
        let barButton = UIBarButtonItem(customView: addButton)
        self.navigationItem.rightBarButtonItem = barButton
        
        //        let toolEditButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.edit, target: self, action: "addSomething:")
        //        toolbarItems = [UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),toolEditButton]
        //        self.navigationController?.setToolbarHidden(false, animated: false)
        
        DispatchQueue.main.async {
            self.tableView!.reloadData()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       // self.navigationController?.isToolbarHidden = true
        
        contacts.removeAll()
        let arrOfIdentifiers = userDefaults.object(forKey: "identifierArr") as? Array<String>
        
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
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        guard contacts.count < 5 else { addButton.isEnabled = false; addButton.alpha = 0.5; return }
        
    }
    
    func didFetchContacts(contacts: [CNContact]) {
        
        for contact in contacts {
            //Give the Contact a userIdentifier
            let uuid = "\(contact.identifier )"
            //Turn the Contact Class into Data
            let contactAsData = archiveContact(contact: contact)
            //Adding userIdentifier to Array
            userIdentifier.append(uuid)
            //Add all identifiers as an array into UserDefaults
            userDefaults.set(userIdentifier, forKey: "identifierArr")
            //Add the Contact as Data in UserDefaults
            userDefaults.set(contactAsData, forKey: uuid)
            userDefaults.synchronize()
        }
        
    }
    
    func archiveContact(contact:CNContact) -> Data {
        let archivedObject = NSKeyedArchiver.archivedData(withRootObject: contact) as NSData
        return archivedObject as Data
    }
    
    
    // MARK: - Table View
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ContactTableViewCell
        
        
        let contact = self.contacts[indexPath.row]
        
        cell.nameLabel.text = "\(contact.givenName) \(contact.familyName)"
        
        
        if contact.phoneNumbers.count > 0 {
            let MobNumVar = (contact.phoneNumbers[0].value ).value(forKey: "digits") as! String
            cell.phoneLabel.text = MobNumVar
        }
        
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    //MARK: -DZNEmptyDataSet Delegates & DataSource
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = "You have no Contacts."
        let attrs = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = "Add your Contacts"
        let attrs = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        return UIImage(named: "newIcon")
    }
    
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let path = indexPath.row
            var arrOfIdentifiers = userDefaults.object(forKey: "identifierArr") as? Array<String>
            
            arrOfIdentifiers?.remove(at: path)
            userDefaults.set(arrOfIdentifiers, forKey: "identifierArr")
            userDefaults.synchronize()
            
            contacts.remove(at: path)
            userIdentifier.remove(at: path)
           

            
            tableView.deleteRows(at: [indexPath], with: .fade)
            if contacts.count <= 4 {
                addButton.isEnabled = true
                addButton.alpha = 1
            }
            
            if contacts.count == 0 {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
        
        
    }
    
    
    // MARK: - Contacts Picker
    
    func showContactsPicker(_ sender: UIBarButtonItem) {
        
        let contactPicker = CNContactPickerViewController()
        contactPicker.delegate = self

//        contactPicker.displayedPropertyKeys = [CNContactPhoneNumbersKey]

//        let predicate = NSPredicate(value: false)
//        let truePredicate = NSPredicate(value: true)
//        contactPicker.predicateForSelectionOfContact = truePredicate
//        contactPicker.predicateForSelectionOfProperty = truePredicate
//        contactPicker.predicateForEnablingContact = truePredicate
        self.present(contactPicker, animated: true, completion: nil)
        
    }

    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        self.didFetchContacts(contacts: [contact])
    }
    
    
    
    lazy var addButton:  UIButton = {
        let button = UIButton(type: UIButtonType.contactAdd)
        button.addTarget(self, action: #selector(showContactsPicker), for: .touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        return button
    }()
    
    lazy var editButton:  UIButton = {
        let button = UIButton(type: UIButtonType.contactAdd)
        //button.addTarget(self, action: #selector(showContactsPicker), for: .touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        return button
    }()
    
}
