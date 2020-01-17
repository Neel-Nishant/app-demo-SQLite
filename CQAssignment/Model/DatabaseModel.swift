//
//  DatabaseModel.swift
//  CQAssignment
//
//  Created by Neel Nishant on 13/01/20.
//  Copyright © 2020 Neel Nishant. All rights reserved.
//

import Foundation
import SQLite

//Class which handles all the connection related to database operations
class DatabaseModel{
    
    static let sharedInstance = DatabaseModel()
    var database: Connection!
    
    let usersTable = Table("userList")
    let id = Expression<Int>("id")
    let name = Expression<String>("name")
    let email = Expression<String>("email")
    let phoneNumber = Expression<String>("phone")
    
    //function to initialize database
    func InitDatabaseModel(completionHandler: @escaping(_ success: Bool, _ error: String?) -> Void){
        do{
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileUrl = documentDirectory.appendingPathComponent("userList").appendingPathExtension(".sqlite3")
            let database = try Connection(fileUrl.path)
            self.database = database
            completionHandler(true, nil)
        }
        catch{
            completionHandler(false,error.localizedDescription)
            print(error.localizedDescription)
        }
        
    }
    
    //function to create Table
    func createTable(completionHandler: @escaping(_ success: Bool, _ error: String?) -> Void){
        let createTable = self.usersTable.create { (table) in
            table.column(self.id, primaryKey: true)
            table.column(self.name)
            table.column(self.email, unique: true)
            table.column(self.phoneNumber, unique: true)
            
        }
        do{
            try self.database.run(createTable)
            print("tableCreated")
            completionHandler(true, nil)
        }
        catch let Result.error(message, code, statement) {
            print("constraint failed: \(message), in \(String(describing: statement)) code:\(code)")
            completionHandler(false, message)
        }
        catch{
            print(error)
            completionHandler(false, error.localizedDescription)
        }
    }
    
    //function to get details of all users from database
    func getUsersData(completionHandler: @escaping(_ success: Bool, _ usersList: [UserDetail]?, _ error: String?) -> Void){
        do{
            var usersArray = [UserDetail]()
            let users = try self.database.prepare(self.usersTable)
            for user in users {
                print("userId: \(user[self.id]) name: \(user[self.name]) email: \(user[self.email]) phone: \(user[self.phoneNumber])")
                let userForModel = UserDetail(uid: user[self.id], userName: user[self.name], email: user[self.email], phoneNumber: user[self.phoneNumber])
                usersArray.append(userForModel)
            }
            completionHandler(true,usersArray,nil)
        }
        catch let Result.error(message, code, statement) where code == SQLITE_CONSTRAINT {
             completionHandler(false,nil,message)
        } catch let error {
            print("insertion failed: \(error)")
            completionHandler(false,nil,error.localizedDescription)
        }
    }
    
    //function to print users
    func printUsers(){
            do{
                let users = try self.database.prepare(self.usersTable)
                for user in users {
                    print("userId: \(user[self.id]) name: \(user[self.name]) email: \(user[self.email]) phone: \(user[self.phoneNumber])")
 
                }
            }
            catch let Result.error(message, code, statement) {
                print("constraint failed: \(message), in \(String(describing: statement)) code:\(code)")
            }
            catch{
                print(error)
            }
    }
    
    //function to update user details in the database
    func updateUser(name: String?, email: String?, phone: String?, userId: Int?, completionHandler: @escaping(_ success: Bool, _ error: String?) -> Void){
        let user = self.usersTable.filter(self.id == userId!)
        
        if name != nil {
            let updateUser = user.update(self.name <- name!)
            
             do {
                 try self.database.run(updateUser)
                 print("User updated")
             }catch{
                 print(error.localizedDescription)
                 completionHandler(false, error.localizedDescription)
             }
        }
        if email != nil {
            let updateUser = user.update(self.email <- email!)
            
             do {
                 try self.database.run(updateUser)
                 print("User updated")
             }catch{
                 print(error.localizedDescription)
                 completionHandler(false, error.localizedDescription)
             }
        }
        if phone != nil {
            let updateUser = user.update(self.phoneNumber <- phone!)
            
             do {
                 try self.database.run(updateUser)
                 print("User updated")
             }catch{
                 print(error.localizedDescription)
                completionHandler(false, error.localizedDescription)
             }
        }
        completionHandler(true, nil)
    }
    
    
    //function to delete user from the database
    func deleteUser(id: Int?, completionHandler:@escaping(_ success: Bool, _ error: String?) -> Void){
        let user = self.usersTable.filter(self.id == id!)
        let deleteUser = user.delete()
           
        do {
            try self.database.run(deleteUser)
            print("User deleted")
            completionHandler(true, nil)
        }
        catch let Result.error(message, code, statement) {
            completionHandler(false, message)
        }
        catch{
            print(error)
            completionHandler(false, error.localizedDescription)
        }
    }
    
    //function to insert user in the database
    func insertUser(name: String, email: String, phone: String, completionHandler: @escaping(_ success: Bool, _ user: UserDetail? ,_ error: String?) -> Void){
        
        let insertUser = self.usersTable.insert(self.name <- name, self.email <- email, self.phoneNumber <- phone)
        var userForModel = UserDetail(uid: nil, userName: name, email: email, phoneNumber: phone)
        do {
            try self.database.run(insertUser)
            
            for user in try self.database.prepare(self.usersTable.filter(self.name == name && self.email == email && self.phoneNumber == phone)){
                userForModel.uid = user[self.id]
            }
            completionHandler(true, userForModel, nil)
        }
        catch let Result.error(message, code, statement) {
            print("constraint failed: \(message), in \(String(describing: statement)) code: \(code)")
            completionHandler(false, nil, message)
        }
        catch{
            print(error)
            completionHandler(false, nil, error.localizedDescription)
        }
    }
    
    //function to drop the table from databse when the user logs out
    func dropTable(completionHandler: (_ success: Bool, _ error: String?) -> Void){
        do{
            try database.run(usersTable.drop())
            print("deleted")
            completionHandler(true, nil)
        }
        catch{
            print("unable to delete")
            completionHandler(false, "unable to drop table")
        }
    }
}
