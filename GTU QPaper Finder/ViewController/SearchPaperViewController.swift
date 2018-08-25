//
//  SearchPaperViewController.swift
//  GTU QPaper Finder
//
//  Created by Ravi on 19/11/17.
//  Copyright © 2017 mammoth. All rights reserved.
//

import UIKit
import Alamofire
import SSZipArchive
import SVProgressHUD
import ZIPFoundation
import GoogleMobileAds

class SearchPaperViewController: UIViewController {
    
    @IBOutlet weak var searchBarPaper: UISearchBar!
    @IBOutlet weak var segmentControlBranch: UISegmentedControl!
    @IBOutlet weak var tableViewSearchedPaper: UITableView!
    @IBOutlet weak var downloadAllView: UIView!
    @IBOutlet weak var lblNoPapers: UILabel!
    
    var possibleURLList = [URL]()
    var validURLList = [URL]()
    var papers = [Paper]()
    var interstitial: GADInterstitial!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        SVProgressHUD.setDefaultMaskType(.black)
        searchBarPaper.delegate = self
        tableViewSearchedPaper.tableFooterView = UIView()
        segmentControlBranch.selectedSegmentIndex = BRANCH_LIST.index(of: SelectedBranch)!
        downloadAllView.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        papers = CoredataManager.shared.getAllPapers()
        tableViewSearchedPaper.reloadData()
        loadInterstatial()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadInterstatial() {
        interstitial = GADInterstitial(adUnitID: InterstitialUnitID)
        let request = GADRequest()
        interstitial.load(request)
    }
    
    func showInterstatial() {
        if interstitial.isReady {
            interstitial.present(fromRootViewController: self)
        }
        loadInterstatial()
    }
    
    func searchForValidPaperURLs(forCode code:String) {
        SVProgressHUD.show()
        
        possibleURLList.removeAll()
        validURLList.removeAll()
        
        for domain in DOMAIN_LIST {
            for exam in EXAM_LIST {
                if var url = URL(string: domain) {
                    url.appendPathComponent(SelectedBranch.rawValue)
                    url.appendPathComponent(exam)
                    url.appendPathComponent("\(code).zip")
                    possibleURLList.append(url)
                }
            }
        }
        
        filterValidURLs(from: possibleURLList) {
            SVProgressHUD.dismiss()
            print("done")
            print("Valid Paper count: \(self.validURLList.count)")
            self.searchBarPaper.resignFirstResponder()
            self.tableViewSearchedPaper.reloadSections([0], with: .automatic)
            self.showInterstatial()
            if self.validURLList.count == 0 {
                self.lblNoPapers.isHidden = false
            } else {
                self.lblNoPapers.isHidden = true
            }
        }
    }
    
    func filterValidURLs(from urls:[URL], complition: (() ->())? = nil) {
        var counter = 0
        for url in urls {
            checkValidation(forUrl: url, complition: { (result) in
                if result {
                    self.validURLList.append(url)
                }
                counter += 1
                if counter == urls.count {
                    if let complition = complition {
                        complition()
                    }
                }
            })
        }
    }
    
    func checkValidation(forUrl url:URL, complition: @escaping (_ result:Bool) ->()) {
        Alamofire.request(url, method: .head, parameters: nil, encoding: URLEncoding.methodDependent, headers: nil)
            .validate(statusCode: 200..<300)
            .responseData { response in
                switch response.result {
                case .success:
                    if let type = response.response?.mimeType, type == "application/x-zip-compressed" {
                        complition(true)
                    } else {
                        complition(false)
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                    complition(false)
                }
        }
    }
    
    @objc func openPaperAction(_ sender:UIButton) {
        let url = validURLList[sender.tag]
        if let paper = papers.filter({$0.url == url.absoluteString}).first {
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
    
    @objc func downloadPaperAction(_ sender:UIButton) {
        
        SVProgressHUD.show()
        
        let url = validURLList[sender.tag]
        var components = url.pathComponents
        let code = components.last!
        components.removeLast()
        let exam = components.last!
        
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsURL.appendingPathComponent("\(exam)-\(code)")
            
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        Alamofire.download(url.absoluteString, to: destination).response { response in
            print(response)
            SVProgressHUD.dismiss()
            if response.error == nil, let zipPath = response.destinationURL {
                print("Downloaded to: \(zipPath)")
                self.unzipFile(atPath: zipPath, downloadURL: url.absoluteString)
            }
            }.downloadProgress { (progress) in
                SVProgressHUD.showProgress(Float(progress.fractionCompleted), status: "Downloading")
        }
    }
    
    func unzipFile(atPath source:URL, downloadURL:String) {
        let destinationURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        SSZipArchive.unzipFile(atPath: source.path, toDestination: destinationURL.path)
        
        let pdfName = source.lastPathComponent.replacingOccurrences(of: "zip", with: "pdf")
        if let originalFile = pdfName.components(separatedBy: "-").last {
            do {
                let destinationPath = destinationURL.appendingPathComponent(pdfName)
                try FileManager.default.moveItem(at: source, to: destinationPath)
                try FileManager.default.removeItem(at: destinationURL.appendingPathComponent(originalFile))
            } catch {
                print(error)
            }
        }
        
        let name = pdfName.replacingOccurrences(of: ".pdf", with: "")
        let components = name.components(separatedBy: "-")
        let exam = components[0]
        let code = components[1]
        
        CoredataManager.shared.saveNewPaper(named: name, code: code, exam: exam, url: downloadURL)
        papers = CoredataManager.shared.getAllPapers()
        self.tableViewSearchedPaper.reloadData()
    }
    
    @IBAction func branchSelected(_ sender: UISegmentedControl) {
        SelectedBranch = BRANCH_LIST[sender.selectedSegmentIndex]
    }
    
    @IBAction func downloadAllPapers(_ sender: UIButton) {
        if let paper = papers.filter({$0.fileName == sender.title(for: .disabled)}).first {
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
    
}

extension SearchPaperViewController: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        UIView.animate(withDuration: 0.3) {
            self.segmentControlBranch.isHidden = false
        }
        return true
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(false, animated: true)
        UIView.animate(withDuration: 0.3) {
            self.segmentControlBranch.isHidden = true
        }
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let code = searchBar.text, !code.isEmpty {
            self.searchForValidPaperURLs(forCode: code)
        }
    }
}

extension SearchPaperViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return validURLList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ValidPaperTableViewCell") as! ValidPaperTableViewCell
        let url = validURLList[indexPath.row]
        let component = url.pathComponents
        cell.lblPaperName.text = component[component.count - 2]
        cell.btnDownload.tag = indexPath.row
        cell.btnDownload.addTarget(self, action: #selector(downloadPaperAction(_:)), for: .touchUpInside)
        cell.btnOpen.tag = indexPath.row
        cell.btnOpen.addTarget(self, action: #selector(openPaperAction(_:)), for: .touchUpInside)
        cell.selectionStyle = .none
        
        if let paper = papers.filter({$0.url == url.absoluteString}).first {
            cell.btnOpen.isHidden = false
            cell.btnDownload.isHidden = true
            cell.btnOpen.setTitle(paper.fileName, for: .disabled)
        } else {
            cell.btnOpen.isHidden = true
            cell.btnDownload.isHidden = false
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        searchBarPaper.resignFirstResponder()
    }
}

