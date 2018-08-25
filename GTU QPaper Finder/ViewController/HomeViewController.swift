//
//  HomeViewController.swift
//  GTU QPaper Finder
//
//  Created by Ravi on 18/11/17.
//  Copyright © 2017 mammoth. All rights reserved.
//

import UIKit
import SafariServices

class HomeViewController: UIViewController {

    @IBOutlet weak var tableViewSavedPaper: UITableView!
    @IBOutlet weak var lblNoSavedPapers: UILabel!
    
    var papers = [Paper]() {
        didSet {
            lblNoSavedPapers.isHidden = papers.count != 0
        }
    }
    
    var expandedSection:Int?
    var paperCodes = [String]()
    var subjectPapers = [String:[Paper]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableViewSavedPaper.tableFooterView = UIView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        papers = CoredataManager.shared.getAllPapers()
        sortPapers()
        tableViewSavedPaper.reloadData()
        
//        papers.forEach({MANAGED_CONTEXT.delete($0)})
//        APP_DELEGATE.saveContext()
//        tableViewSavedPaper.reloadSections([0], with: .automatic)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func sortPapers() {
        paperCodes.removeAll()
        subjectPapers.removeAll()
        for paper in papers {
            if !paperCodes.contains(paper.code!) {
                paperCodes.append(paper.code!)
            }
        }
        
        for code in paperCodes {
            subjectPapers[code] = papers.filter({$0.code! == code})
        }
    }
    
    @objc func deletePaper(_ sender: UIButton) {
        let paper = papers[sender.tag]
        let alert = UIAlertController(title: "Are you sure?", message: "Delete \(paper.displayName!)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
            var pdfPath = documentsUrl
            pdfPath.appendPathComponent(paper.fileName!)
            if FileManager.default.fileExists(atPath: pdfPath.path) {
                do {
                    try FileManager.default.removeItem(at: pdfPath)
                    let section = self.paperCodes.index(of: paper.code!)!
                    let code = paper.code!
                    MANAGED_CONTEXT.delete(paper)
                    APP_DELEGATE.saveContext()
                    self.papers = CoredataManager.shared.getAllPapers()
                    self.sortPapers()
                    if self.paperCodes.count == 0 || (self.subjectPapers[code] == nil) {
                        self.tableViewSavedPaper.reloadData()
                    } else {
                        self.tableViewSavedPaper.reloadSections([section], with: .automatic)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { // in half a second...
                            self.tableViewSavedPaper.reloadData()
                        }
                    }
                } catch {
                    showAlertMessage(error.localizedDescription)
                }
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func renamePaper(_ sender: UIButton) {
        let paper = papers[sender.tag]
        let renameVC = storyboard?.instantiateViewController(withIdentifier: "RenamePaperViewController") as! RenamePaperViewController
        renameVC.paper = paper
        renameVC.delegate = self
        renameVC.modalPresentationStyle = .overCurrentContext
        self.present(renameVC, animated: true, completion: nil)
    }
    
    @objc func toggleSection(_ sender:UIButton) {
        if expandedSection == sender.tag {
            expandedSection = nil
            print("collapse")
        } else {
            expandedSection = sender.tag
            print("expand")
        }
        
//        var indexPaths = [IndexPath]()
//        for i in 0..<tableViewSavedPaper.numberOfRows(inSection: sender.tag) {
//            indexPaths.append(IndexPath(row: i, section: sender.tag))
//        }
//        tableViewSavedPaper.reloadRows(at: indexPaths, with: .automatic)
        
        tableViewSavedPaper.reloadSections([sender.tag], with: .automatic)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { // in half a second...
            self.tableViewSavedPaper.reloadData()
        }
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return paperCodes.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subjectPapers[paperCodes[section]]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SavedPaperTableViewCell") as! SavedPaperTableViewCell
        
        let code = paperCodes[indexPath.section]
        let paper = subjectPapers[code]![indexPath.row]
        cell.lblPaperName.text = paper.displayName
        cell.btnEdit.tag = papers.index(of: paper)!
        cell.btnDelete.tag = papers.index(of: paper)!
        cell.btnEdit.addTarget(self, action: #selector(renamePaper(_:)), for: .touchUpInside)
        cell.btnDelete.addTarget(self, action: #selector(deletePaper(_:)), for: .touchUpInside)
        cell.unreadView.backgroundColor = paper.isOpened ? .clear : self.view.tintColor
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SavedPaperHeaderTableViewCell") as! SavedPaperHeaderTableViewCell
        let code = paperCodes[section]
        cell.lblPaperCode.text = code
        cell.btnExpand.tag = section
        cell.btnExpand.addTarget(self, action: #selector(toggleSection(_:)), for: .touchUpInside)
        cell.lblPaperCount.text = String(subjectPapers[code]!.count)
        
        var angle:CGFloat!
        
        if expandedSection == section {
            angle = .pi
        } else {
            angle = 0
        }
        
        let tr = CGAffineTransform.identity.rotated(by: angle)
        cell.imageViewArrow.transform = tr
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let expandedSection = expandedSection, expandedSection == indexPath.section {
            return 50
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let code = paperCodes[indexPath.section]
        let paper = subjectPapers[code]![indexPath.row]
        if !paper.isOpened {
            paper.isOpened = true
            APP_DELEGATE.saveContext()
        }
        var pdfURL = documentsUrl
        pdfURL.appendPathComponent(paper.fileName!)
        let pdfVC = storyboard?.instantiateViewController(withIdentifier: "PDFViewController") as! PDFViewController
        pdfVC.paper = paper
        let navC = UINavigationController(rootViewController: pdfVC)
        self.present(navC, animated: true, completion: nil)
    }
}

extension HomeViewController: RenameDelegate {
    func paperRenamed(paper: Paper) {
        papers = CoredataManager.shared.getAllPapers()
        sortPapers()
        self.tableViewSavedPaper.reloadData()
    }
}
