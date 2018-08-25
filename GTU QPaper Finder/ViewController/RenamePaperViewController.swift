//
//  RenamePaperViewController.swift
//  GTU QPaper Finder
//
//  Created by Ravi on 24/11/17.
//  Copyright © 2017 mammoth. All rights reserved.
//

import UIKit

protocol RenameDelegate {
    func paperRenamed(paper:Paper)
}

class RenamePaperViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var tfPapername: UITextField!
    
    var paper:Paper!
    var delegate:RenameDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        containerView.layer.cornerRadius = 5
        tfPapername.text = paper.displayName
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveAction(_ sender: UIButton) {
        if let paperName = tfPapername.text, !paperName.isEmpty {
            paper.displayName = paperName
            APP_DELEGATE.saveContext()
            self.dismiss(animated: true, completion: {
                self.delegate?.paperRenamed(paper: self.paper)
            })
        }
    }
    
    @IBAction func cancelAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension RenamePaperViewController:UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
