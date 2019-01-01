//
//  EntryController.swift
//  JournalCloudKit
//
//  Created by Steve Lederer on 12/30/18.
//  Copyright © 2018 Steve Lederer. All rights reserved.
//

import Foundation
import CloudKit

class EntryController {
    
    static let shared = EntryController()
    
    private init() {}
    
    var entries: [Entry] = []
    
    let privateDB = CKContainer.default().privateCloudDatabase
    
    func save(entry: Entry, completion: @escaping (Bool) -> ()) {
        let entryRecord = CKRecord(entry: entry)
        
        privateDB.save(entryRecord) { (record, error) in
            if let error = error {
                print("❌ There was an error in \(#function) ; \(error.localizedDescription) ❌")
                completion(false)
                return
            }
            
            guard let record = record,
                let entry = Entry(ckRecord: record) else { completion(false) ; return }
            self.entries.append(entry)
            completion(true)
        }
    }
    
    func addEntryWith(title: String, body: String, completion: @escaping (Bool) -> ()) {
        let entry = Entry(title: title, body: body)
        save(entry: entry) { (success) in
            if !success {
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    func fetchEntries(completion: @escaping (Bool) -> ()) {
        let query = CKQuery(recordType: Constants.recordKey, predicate: NSPredicate(value: true))
        privateDB.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print("❌ There was an error in \(#function) ; \(error.localizedDescription) ❌")
                completion(false)
                return
            }
            
            guard let records = records else { completion(false) ; return }
            let entries = records.compactMap({ (record) -> Entry? in
                return Entry(ckRecord: record)
            })
            self.entries = entries
            completion(true)
            
        }
    }
    
    func deleteEntry(entry: Entry, completion: @escaping (Bool) -> ()) {
        guard let index = EntryController.shared.entries.index(of: entry) else { return }
        EntryController.shared.entries.remove(at: index)
        
        privateDB.delete(withRecordID: entry.ckRecordID) { (record, error) in
            if let error = error {
                print("❌ There was an error in \(#function) ; \(error.localizedDescription) ❌")
                completion(false)
                return
            } else {
                print("Record deleted from CloudKit database")
                completion(true)
            }
        }
    }
    
    func updateEntry(entry: Entry, title: String, body: String, completion: @escaping (Bool) -> ()) {
        //local updates
        entry.title = title
        entry.body = body
        
        //remote updates
        privateDB.fetch(withRecordID: entry.ckRecordID) { (record, error) in
            if let error = error {
                print("❌ There was an error in \(#function) ; \(error.localizedDescription) ❌")
                completion(false)
                return
            }
            
            guard let record = record else { completion(false) ; return }
            
            record[Constants.titleKey] = title
            record[Constants.bodyKey] = body
            
            let operation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
            operation.savePolicy = .changedKeys
            operation.queuePriority = .high
            operation.qualityOfService = .userInitiated
            operation.modifyRecordsCompletionBlock = { (records, recordIDs, error) in
                completion(true)
            }
            self.privateDB.add(operation)
            
        }
    }
}
