//
//  UserDetailsListViewController.swift
//  CQAssignment
//
//  Created by Neel Nishant on 12/01/20.
//  Copyright © 2020 Neel Nishant. All rights reserved.
//

import UIKit
import SQLite
import Firebase
class UserDetailsListViewController: UIViewController {

    
    var userDetailArray: [UserDetail]!
    
    @IBOutlet weak var userTableView: UITableView!
    
    @IBOutlet weak var toastLabel: UILabel!
    
    @IBOutlet weak var toastContainer: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

        //Call to Initialize connection to database
        DatabaseModel.sharedInstance.InitDatabaseModel { (success, error) in
            if error != nil {
                self.showToast(toastMessage: error!)
            }
        }
        
        // Call to create Table
        DatabaseModel.sharedInstance.createTable { (success, error) in
            if error != nil{
                self.showToast(toastMessage: error!)
            }
        }
        
        refreshTable()
    }
    
    //function to get the user  values stored in the database
    func refreshTable(){
        userDetailArray = [UserDetail]()

        
        DatabaseModel.sharedInstance.getUsersData { (success, userslist, error) in
            if success {
                self.userDetailArray = userslist!
                self.userTableView.reloadData()
            }
            else{
                self.showToast(toastMessage: error!)
            }
        }
        
    }

    func showToast(toastMessage: String){
        print("toastMessage: \(toastMessage)")
        var timer: Timer?
        DispatchQueue.main.async {
            self.toastLabel.text = toastMessage
            UIView.animate(withDuration: 2.0, animations: {
                self.toastContainer.alpha = 1
            }) { (anim) in
                timer?.invalidate()
                timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false, block: { (timer) in
                    UIView.animate(withDuration: 2.0) {
                        self.toastContainer.alpha = 0
                    }
                })
            }
        }
    }

    //Helper function to update the user details either from the button or by swiping
    func updateUserHelper(id: Int?, indexpath: IndexPath?){
        let alert = UIAlertController(title: "Update User", message: "Update user details in Database", preferredStyle: .alert)
        alert.addTextField { (tf) in
            
            tf.placeholder = "User Id"
            tf.keyboardType = .numberPad
            if(indexpath != nil){
                tf.text = String(id!)
                tf.isEnabled = false
            }
            
            
        }
        alert.addTextField { (tf) in
             tf.placeholder = "Name"
        }
        alert.addTextField { (tf) in
            tf.placeholder = "Email"
        }
        alert.addTextField { (tf) in
            tf.placeholder = "Phone Number"
            tf.keyboardType = .phonePad
        }
        let action = UIAlertAction(title: "Submit", style: .default) { (_) in
            let userIdString = alert.textFields?.first?.text
            var name = alert.textFields?[1].text
            var email = alert.textFields?[2].text
            var phone = alert.textFields?.last?.text
            
            if(userIdString != ""){
                 let userId = Int(userIdString!)

                if name == ""{
                    name = nil
                }
                if email == ""{
                    email = nil
                }
                
                if phone == ""{
                    phone = nil
                }
                //call to database to update the user
                DatabaseModel.sharedInstance.updateUser(name: name, email: email, phone: phone, userId: userId) { (success, error) in
                    if error != nil {
                        self.showToast(toastMessage: error!)
                    }
                }
            }
            else {
                self.showToast(toastMessage: "ID is important for updating the details")
            }
            if(indexpath != nil){
                if name != nil {
                    self.userDetailArray[indexpath!.row].userName = name!
                }
                if email != nil {
                    self.userDetailArray[indexpath!.row].email = email!
                }
                if phone != nil {
                    self.userDetailArray[indexpath!.row].phoneNumber = phone!
                }
                
                self.userTableView.reloadRows(at: [indexpath!], with: .automatic)
            }
            else{
                self.refreshTable()
            }
            

        }
        let action2 = UIAlertAction(title: "Cancel", style: .default, handler: nil)
       
        alert.addAction(action)
        alert.addAction(action2)
        present(alert, animated: true, completion: nil)
    }
    
    //function to delete the user when swiped
    func deleteDataFromTable(id: Int?, indexPath: IndexPath?){
        deleteDataHelper(id: id!)
        userDetailArray.remove(at: indexPath!.row)
        userTableView.deleteRows(at: [IndexPath(row: indexPath!.row, section: 0)], with: .automatic)
    }
    
    //helper function to delete the user details
    func deleteDataHelper(id: Int){
        DatabaseModel.sharedInstance.deleteUser(id: id) { (success, error) in
            if error != nil {
                self.showToast(toastMessage: error!)
            }
        }
    }
    
    //insert a new user
    @IBAction func insertUserTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Insert User", message: "Insert user details to insert into Database", preferredStyle: .alert)
        alert.addTextField { (tf) in
            tf.placeholder = "Name"
        }
        alert.addTextField { (tf) in
            tf.placeholder = "Email"
        }
        alert.addTextField { (tf) in
            tf.placeholder = "Phone Number"
            tf.keyboardType = .phonePad
        }
        let action = UIAlertAction(title: "Submit", style: .default) { (_) in
            let name = alert.textFields?.first?.text
            let email = alert.textFields?[1].text
            let phone = alert.textFields?.last?.text
            if(name != "" && email != "" && phone != ""){

                // call to insert new user
                DatabaseModel.sharedInstance.insertUser(name: name!, email: email!, phone: phone!) { (success, userToEnter, error) in
                    if success{
                        self.userDetailArray.append(userToEnter!)
                        self.userTableView.insertRows(at: [IndexPath(row: self.userDetailArray.count-1, section: 0)], with: .automatic)
                    }
                    if error != nil {
                        self.showToast(toastMessage: error!)
                    }
                }
            }
            else{
                self.showToast(toastMessage: "Unable to add the user. One or more fields are empty")
            }
            
        }
        let action2 = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        alert.addAction(action)
        alert.addAction(action2)
        present(alert, animated: true, completion: nil)
    }
    
    
    //update from button
    @IBAction func updateUser(_ sender: UIButton) {
        updateUserHelper(id: nil, indexpath: nil)
    }
    
    //This function logs out the user from the Firebase console and also deletes the table created
    @IBAction func logOutPressed(_ sender: UIButton) {
        UserDefaults.standard.removeObject(forKey: "user")
    
        let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
            print("logged out")
            self.dismiss(animated: true, completion: nil)
            self.navigationController?.popViewController(animated: true)
        } catch let signOutError as NSError {
          print ("Error signing out: %@", signOutError)
        }

        DatabaseModel.sharedInstance.dropTable { (success, error) in
            if error != nil {
                self.showToast(toastMessage: error!)
            }
        }
    }
    
}

//TableView methods
extension UserDetailsListViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userDetailArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as? UserDetailTableViewCell
        
        cell?.nameLabel.text = ": \(userDetailArray[indexPath.row].userName!)"
       
        
        cell?.phoneNumberLabel.text = ": \(userDetailArray[indexPath.row].phoneNumber!)"
        
        
        cell?.emailLabel.text = ": \(userDetailArray[indexPath.row].email!)"
      
        
        cell?.idLabel.text = ": \(String(userDetailArray[indexPath.row].uid!))"
       
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 189.0
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if(editingStyle == .delete){
            let id = userDetailArray[indexPath.row].uid
            deleteDataFromTable(id: id, indexPath: indexPath)
        }
    }

    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let updateAction = UIContextualAction(style: .normal, title: "Update") { (ac: UIContextualAction, view: UIView, success: (Bool) -> Void) in
            self.updateUserHelper(id: self.userDetailArray[indexPath.row].uid!, indexpath: indexPath)
        }
        updateAction.backgroundColor = .orange
        return UISwipeActionsConfiguration(actions: [updateAction])

    }
    
    
}
