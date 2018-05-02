//
//  SelectPublication.swift
//  Access News Reader
//
//  Created by Society for the Blind on 4/13/18.
//  Copyright © 2018 Society for the Blind. All rights reserved.
//

import UIKit

class SelectPublication: UITableViewController {

    let publications =
        [ "Sports"
        , "News"
        , "Sacramento News & Review"
        , "Sacramento Press"
        , "Sacramento Business Journal"
        , "Davis Enterprise"
        , "Roseville Press Tribune"
        , "Woodland Daily Democrat"
        , "Carmichael Times"
        , "Comstocks"
        , "SacTown"
        , "Sacramento Magazine"
        , "Auburn Journal"
        , "Grass Valley-Nevada City Union"
        , "Modesto Bee"
        , "Stockton Record"
        , "El Dorado County Mountain Democrat"
        , "Santa Rosa Press Democrat"
        , "SF Gate"
        , "San Francisco Bay Guardian (RARELY UPDATES)"
        , "East Bay Times"
        , "SF Weekly"
        , "KQED Bay Area Bites"
        , "Senior News"
        , "North Coast Journal"
        , "Mad River Union"
        , "Eureka Times Standard"
        , "Ferndale Enterprise"
        , "Earle Baum Center newsletter"
        , "Braille Monitor"
        , "Sierra Services for the Blind"
        , "UC Davis - Achieve a healthy weight"
        , "Matter of Balance"
        , "Yuba-Sutter Meals on Wheels"
        ]

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

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.publications.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // https://stackoverflow.com/questions/34730848/xcode-error-unable-to-dequeue-a-cell-with-identifier-mealtableviewcell
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        // Configure the cell...
        cell.textLabel?.text = self.publications[indexPath.row]

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        /* As it stands at the moment, this needs to stay here so that
           `RecordViewController` is the navigation controller's top view
           controller below.
        */


        let recordViewController = self.navigationController?.viewControllers[0] as! RecordViewController


        /* Enable "Record" button, because a publication has been
           selected here.
        */
        recordViewController.toolbarItems?[1].isEnabled = true
        
        let mainTVC = recordViewController.childViewControllers.first as! MainTableViewController
//        let publicationCellLabel = mainTVC.tableView.visibleCells[0].textLabel!
//        publicationCellLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
//        publicationCellLabel.textColor = UIColor(red: 0.0, green: 0.478, blue: 1.0, alpha: 1.0)
//        publicationCellLabel.text = self.publications[indexPath.row]


        mainTVC.selectedPublication.text = self.publications[indexPath.row]

        self.navigationController?.popViewController(animated: true)
    }
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
