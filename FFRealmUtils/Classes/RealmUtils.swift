//
//  RealmUtils.swift
//  FFRealmUtils
//
//  Created by Artem Kalmykov on 10/17/17.
//

import Foundation
import RealmSwift

extension Realm
{
    public static var shared: Realm
    {
        return try! Realm()
    }
}

extension Object
{
    public func addToRealm(update: Bool = true)
    {
        Realm.shared.add(self, update: update)
    }
    
    public func deleteFromRealm()
    {
        Realm.shared.delete(self)
    }
}
