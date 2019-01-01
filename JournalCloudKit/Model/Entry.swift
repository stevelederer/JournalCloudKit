//
//  Entry.swift
//  JournalCloudKit
//
//  Created by Steve Lederer on 12/30/18.
//  Copyright © 2018 Steve Lederer. All rights reserved.
//

import Foundation
import CloudKit

struct Constants {
    static let titleKey = "Title"
    static let bodyKey = "Body"
    static let recordKey = "Entry"
}

class Entry {

    var title: String
    var body: String
    var ckRecordID: CKRecord.ID
    
    init(title: String, body: String, ckRecordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)) {
        self.title = title
        self.body = body
        self.ckRecordID = ckRecordID
    }
    
    convenience init?(ckRecord: CKRecord) {
        guard let title = ckRecord[Constants.titleKey] as? String,
            let body = ckRecord[Constants.bodyKey] as? String else { return nil }
        
        self.init(title: title, body: body, ckRecordID: ckRecord.recordID)
    }
}

extension CKRecord {
    convenience init(entry: Entry) {
        self.init(recordType: Constants.recordKey, recordID: entry.ckRecordID)
        
        self.setValue(entry.title, forKey: Constants.titleKey)
        self.setValue(entry.body, forKey: Constants.bodyKey)
    }
}

extension Entry: Equatable {
    static func == (lhs: Entry, rhs: Entry) -> Bool {
        return lhs.title == rhs.title && lhs.body == rhs.body
    }
}
