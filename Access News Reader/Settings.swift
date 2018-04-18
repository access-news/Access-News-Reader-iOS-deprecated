//
//  Settings.swift
//  Access News Reader
//
//  Created by Society for the Blind on 4/17/18.
//  Copyright © 2018 Society for the Blind. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuthUI

class Settings: UITableViewController {

    let appDelegate = (UIApplication.shared.delegate as? AppDelegate)!

    @IBOutlet weak var changeEmailField: UITextField!
    // TODO See issue #14 - Make the keyboard take the role of this button
    @IBAction func submitEmailChange(_ sender: Any) {
        if let newEmail = self.changeEmailField.text {
            self.appDelegate.authUI?.auth?.currentUser?.updateEmail(to: newEmail)
        } else {
            // TODO: modal popup: "Please specify a valid email address."
        }
    }

    /* Could've just put
         self.navigationItem.rightBarButtonItem?.target = self
         self.navigationItem.rightBarButtonItem?.action = #selector(logoutTapped)
     in `viewDidLoad`, but this solution is grouped nicely in one place.
    */	
    /* TO REMEMBER
       When Settings table view controller was created and connected as a "show"
       segue, it wasn't possible to create a Logout button on the navigation bar.

       The only solution that worked:
       1. Delete "show" segue
       2. Add "push (deprecated" segue
       3. Add the UIBarButtonItem
       4. Delete "push" segue
       5. Reconnect with "show" segue
    */
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    @IBAction func logoutTapped(_ sender: Any) {
        do {
            // TODO Would this work without any network connection?
            try appDelegate.authUI?.auth?.signOut()
        } catch {
            NSLog("Error: Unable to log out of Firebase")
        }

        self.appDelegate.defaults.set(false, forKey: Constants.userLoggedIn)

        let fuiLoginVC = FUIEmailEntryViewController(authUI: FUIAuth.defaultAuthUI()!)
        let navController = UINavigationController(rootViewController: fuiLoginVC)
        self.present(navController, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return 0
//    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
