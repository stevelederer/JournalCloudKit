//
//  EntryDetailViewController.swift
//  JournalCloudKit
//
//  Created by Steve Lederer on 12/31/18.
//  Copyright © 2018 Steve Lederer. All rights reserved.
//

import UIKit

class EntryDetailViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    // MARK: - Properties
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var bodyTextView: UITextView!
    
    var entry: Entry?
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
    }
    
    // MARK: - Setup
    
    func updateViews() {
        if let entry = entry {
            self.titleTextField.text = entry.title
            self.bodyTextView.text = entry.body
            navigationItem.title = entry.title
        } else {
            navigationItem.title = "New Entry"
            self.titleTextField.text = ""
            let placeholderText = NSAttributedString(string: "Enter a title...", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
            self.titleTextField.attributedPlaceholder = placeholderText
        }
    }
    
    // MARK: - Actions
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        if titleTextField.text == "" {
            presentEmptyTitleAlert()
        } else {
            guard let title = titleTextField.text,
                let body = bodyTextView.text else { return }
            if let entry = entry {
                EntryController.shared.updateEntry(entry: entry, title: title, body: body) { (success) in
                    if success {
                        print("✅ Success updating entry")
                        DispatchQueue.main.async {
                            self.navigationController?.popViewController(animated: true)
                        }
                    } else {
                        print("❌ Failure updating entry")
                    }
                }
            } else {
                EntryController.shared.addEntryWith(title: title, body: body) { (success) in
                    if success {
                        print("✅ Success adding new entry")
                        DispatchQueue.main.async {
                            self.navigationController?.popViewController(animated: true)
                        }
                    } else {
                        print("❌ Failure adding new entry")
                    }
                }
            }
            
        }
        
    }
    
    
    @IBAction func clearButtonTapped(_ sender: UIButton) {
        presentClearAlert()
    }
    
    func presentClearAlert() {
        let clearAlertController = UIAlertController(title: "Clear?", message: "Are you sure you want to clear?", preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        let clearAction = UIAlertAction(title: "Clear", style: .destructive) { (_) in
            self.titleTextField.text = ""
            self.bodyTextView.text = "Your entry goes here..."
        }
        clearAlertController.addAction(cancelAction) ; clearAlertController.addAction(clearAction)
        self.present(clearAlertController, animated: true)
    }
    
    func presentEmptyTitleAlert() {
        let emptyTitleAlertController = UIAlertController(title: "Yo!", message: "Your title cannot be empty,", preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
        emptyTitleAlertController.addAction(okayAction)
        self.present(emptyTitleAlertController, animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        titleTextField.resignFirstResponder()
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if bodyTextView.text == "Your entry goes here..." {
            bodyTextView.text = ""
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        bodyTextView.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
}
