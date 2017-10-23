//
//  RealmUtils.swift
//  FFRealmUtils
//
//  Created by Artem Kalmykov on 10/17/17.
//

import Foundation
import RealmSwift
import Marshal

extension Realm
{
    public static var shared: Realm
    {
        do
        {
            return try Realm()
        }
        catch let error
        {
            print("Realm initialization error: " + error.localizedDescription)
            exit(0)
        }
    }
    
    public func finishWrite()
    {
        do
        {
            try self.commitWrite()
        }
        catch let error
        {
            print("Realm write error: " + error.localizedDescription)
        }
    }
    
    public func safeWrite(_ block: (() -> Void))
    {
        if self.isInWriteTransaction
        {
            block()
        }
        else
        {
            do
            {
                try self.write(block)
            }
            catch let error
            {
                print("Realm write error: " + error.localizedDescription)
            }
        }
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
    
    public class func parseObject<T: ValueType>(_ rawObject: Any?) -> T?
    {
        guard let rawObject = rawObject as? JSONObject else
        {
            return nil
        }
        
        do
        {
            Realm.shared.beginWrite()
            let value: T? = try rawObject.parseValue()
            Realm.shared.finishWrite()
            return value
        }
        catch let error
        {
            Realm.shared.cancelWrite()
            self.handleError(error)
            return nil
        }
    }
    
    public class func parseObject<T: ValueType>(_ rawObject: Any?) throws -> T
    {
        guard let rawObject = rawObject as? JSONObject else
        {
            throw MarshalError.typeMismatch(expected: T.self, actual: Any.self)
        }
        
        do
        {
            Realm.shared.beginWrite()
            let value: T = try rawObject.parseValue()
            Realm.shared.finishWrite()
            return value
        }
        catch
        {
            Realm.shared.cancelWrite()
            throw MarshalError.typeMismatch(expected: T.self, actual: Any.self)
        }
    }
    
    public class func parseObjects<T: ValueType>(_ rawObjects: Any?) -> [T]
    {
        guard let rawObjects = rawObjects as? [JSONObject] else
        {
            return []
        }
        
        do
        {
            Realm.shared.beginWrite()
            let values: [T] = try rawObjects.parseValues()
            Realm.shared.finishWrite()
            return values
        }
        catch let error
        {
            Realm.shared.cancelWrite()
            self.handleError(error)
            return []
        }
    }
    
    private class func handleError(_ error: Error)
    {
        if let marshalError = error as? MarshalError
        {
            print("Marshal parsing error: " + marshalError.description)
        }
        else
        {
            print("Unknown parsing error: " + error.localizedDescription)
        }
    }
}

