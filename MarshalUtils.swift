//
//  MarshalUtils.swift
//  FFRealmUtils
//
//  Created by Artem Kalmykov on 10/17/17.
//

import Foundation
import Marshal
import RealmSwift

extension Dictionary: ValueType
{
    public static func value(from object: Any) throws -> Dictionary
    {
        guard let dict = object as? Dictionary else
        {
            throw MarshalError.typeMismatch(expected: String.self, actual: type(of: object))
        }
        
        return dict
    }
}

extension JSONParser
{
    fileprivate static var dictionaryKey: String
    {
        return "_Marshal_DictionaryKey"
    }
    
    fileprivate static var dictionaryValue: String
    {
        return "_Marshal_DictionaryValue"
    }
}

extension MarshaledObject
{
    public func valueForDictionaryKey<T: ValueType>() throws -> T
    {
        return try self.value(for: JSONParser.dictionaryKey)
    }
    
    public func valueForDictionaryValue<T: ValueType>() throws -> T
    {
        return try self.value(for: JSONParser.dictionaryValue)
    }
    
    public func valueForDictionaryKey<T: ValueType>() throws -> [T]
    {
        return try self.value(for: JSONParser.dictionaryKey)
    }
    
    public func valueForDictionaryValue<T: ValueType>() throws -> [T]
    {
        return try self.value(for: JSONParser.dictionaryValue)
    }
    
    public func dictionaryTransformedValues<T: ValueType>(for key: KeyType) throws -> [T]
    {
        guard let castedSelf = self as? [AnyHashable : Any] else
        {
            return []
        }
        
        return try castedSelf.dictionaryTransformedValues(for: key)
    }
    
    public func transformDictionaryValues<T: ValueType>() throws -> [T]
    {
        guard let castedSelf = self as? [AnyHashable : Any] else
        {
            return []
        }
        
        return try castedSelf.transformDictionaryValues()
    }
    
    public func combinedDictionaryOfDictionariesOfArrays<T: ValueType>(for key: KeyType) throws -> [T]
    {
        guard let dictValue: [String : Any] = try self.value(for: key), dictValue is [String : [[String : Any]]] else
        {
            throw MarshalError.typeMismatchWithKey(key: key.stringValue, expected: [AnyHashable : Any].self, actual: self.self)
        }
        
        var transformed: [[String : Any]] = []
        
        for obj in (dictValue as! [String : [[String : Any]]])
        {
            for var subObj in obj.value
            {
                subObj[JSONParser.dictionaryKey] = obj.key
                transformed.append(subObj)
            }
        }
        
        return try transformed.map {
            let value = try T.value(from: $0)
            guard let element = value as? T else
            {
                throw MarshalError.typeMismatch(expected: T.self, actual: type(of: value))
            }
            return element
        }
    }
    
    public func idMap<T: Object, K: ValueType>(forKey key: KeyType, idKey: KeyType, idType: K.Type) throws -> [T]
    {
        let ids: [K?] = try self.value(for: key)
        return ids.flatMap({ id in
            guard let id = id else
            {
                return nil
            }
            
            return Realm.shared.objects(T.self).filter("\(idKey) == %@", id).first
        })
    }
}

extension Dictionary
{
    public func dictionaryTransformedValues<T: ValueType>(for key: KeyType) throws -> [T]
    {
        guard let dictValue: [String : Any] = try self.value(for: key) else
        {
            throw MarshalError.typeMismatchWithKey(key: key.stringValue, expected: [AnyHashable : Any].self, actual: self.self)
        }
        
        return try dictValue.transformDictionaryValues()
    }
    
    public func transformDictionaryValues<T: ValueType>() throws -> [T]
    {
        let transformed = self.map({[JSONParser.dictionaryKey: $0, JSONParser.dictionaryValue: $1]})
        
        return try transformed.map {
            let value = try T.value(from: $0)
            guard let element = value as? T else
            {
                throw MarshalError.typeMismatch(expected: T.self, actual: type(of: value))
            }
            return element
        }
    }
}
