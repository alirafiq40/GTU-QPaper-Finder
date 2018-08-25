//
//  Constant.swift
//  GTU QPaper Finder
//
//  Created by Ravi on 18/11/17.
//  Copyright © 2017 mammoth. All rights reserved.
//

import UIKit

let APP_DELEGATE = UIApplication.shared.delegate as! AppDelegate
let USER_DEFAULT = UserDefaults.standard
let MANAGED_CONTEXT = APP_DELEGATE.persistentContainer.viewContext
//Live
let InterstitialUnitID = "ca-app-pub-1884240396742964/7503339364"
//Demo
//let InterstitialUnitID = "ca-app-pub-3940256099942544/4411468910"

var documentsUrl:URL {
    return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
}

var LAUNCH_COUNT:Int {
    set {
        USER_DEFAULT.set(newValue, forKey: "LAUNCH_COUNT")
        USER_DEFAULT.synchronize()
    }
    get {
        return USER_DEFAULT.integer(forKey: "LAUNCH_COUNT")
    }
}

var PAPER_VIEW_COUNT:Int {
    set {
        USER_DEFAULT.set(newValue, forKey: "PAPER_VIEW_COUNT")
        USER_DEFAULT.synchronize()
    }
    get {
        return USER_DEFAULT.integer(forKey: "PAPER_VIEW_COUNT")
    }
}

let EXAM_LIST = ["Winter_Exam_2018",
                 "Summer_Exam_2018",
                 "Winter_Exam_2017",
                 "Summer_Exam_2017",
                 "Winter_Exam_2016",
                 "Summer_Exam_2016",
                 "Winter_Exam_2015",
                 "Summer_Exam_2015",
                 "Winter_Exam_2014",
                 "Summer_Exam_2014",
                 "Winter_Rem2013",
                 "Summer_Exam_2013",
                 "Winter_Exam_2012",
                 "Summmer_Exam_2012",
                 "NovDec11JanFeb12"]

let DOMAIN_LIST = ["http://files.gtu.ac.in/GTU_Papers/","http://www.gtu.ac.in/GTU_Papers/"]

enum Branch:String {
    case DE = "DE"
    case BE = "BE"
    case ME = "ME"
}

let BRANCH_LIST:[Branch] = [.DE,.BE,.ME]

var firstLaunch:Bool {
    set {
        USER_DEFAULT.set(newValue, forKey: "first_launch")
        USER_DEFAULT.synchronize()
    }
    get {
        return USER_DEFAULT.bool(forKey: "first_launch")
    }
}

var selectedBranch:Int {
    set {
        USER_DEFAULT.set(newValue, forKey: "selectedBranch")
        USER_DEFAULT.synchronize()
    }
    get {
        return USER_DEFAULT.integer(forKey: "selectedBranch")
    }
}

var SelectedBranch:Branch {
    set {
        USER_DEFAULT.set(newValue.rawValue, forKey: "SelectedBranch")
        USER_DEFAULT.synchronize()
    }
    get {
        if let result = USER_DEFAULT.string(forKey: "SelectedBranch") {
            return Branch(rawValue: result)!
        }
        return .DE
    }
}

func showAlertMessage(title:String? = nil, _ message:String, complition: (() ->())? = nil) {
    let rootVC = UIApplication.topViewController()
    var alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)
    if let title = title {
        alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    }
    alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (action) in
        if let complition = complition {
            complition()
        }
    }))
    rootVC?.present(alert, animated: true, completion: nil)
}
