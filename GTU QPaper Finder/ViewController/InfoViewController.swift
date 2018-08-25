//
//  InfoViewController.swift
//  GTU QPaper Finder
//
//  Created by Ravi on 02/12/17.
//  Copyright © 2017 mammoth. All rights reserved.
//

import UIKit
import MessageUI

class InfoViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func sendMail(_ sender: UIButton) {
        UIPasteboard.general.string = sender.title(for: .normal)
        showAlertMessage("Email copied")
    }
}

extension InfoViewController: MFMailComposeViewControllerDelegate, UINavigationControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if let error = error {
            showAlertMessage(error.localizedDescription)
        }
        controller.dismiss(animated: true, completion: nil)
    }
}
