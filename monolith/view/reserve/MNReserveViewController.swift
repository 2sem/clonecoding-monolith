//
//  MNReserveViewController.swift
//  monolith
//
//  Created by 영준 이 on 2021/04/10.
//

import UIKit

class MNReserveViewController: UIViewController {

    let defaultTicket: Int = 339;
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func onClosePopup(_ segue: UIStoryboardSegue){
        
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let purchaseView = segue.destination as? MNTicketPurchaseViewController{
            purchaseView.ticket = self.defaultTicket;
        }
    }
}
