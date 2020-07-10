//
//  JSONHelper.swift
//  Hibbett
//
//  Created by Thibault Klein on 6/1/17.
//  Copyright © 2017 Prolific Interactive. All rights reserved.
//

import Foundation

public typealias JSON = [String: Any]

/// JSON helper errors.
///
/// - jsonFileNotFound: The JSON file could not be found.
/// - jsonDeserializationFailed: The JSON failed to deserialize.
/// - jsonFormatInvalid: The JSON format is invalid.
public enum JSONError: Swift.Error {

    /// Error for the case that a file was not found.
    case jsonFileNotFound(filePath: String)

    /// Error for the case that the JSON serializer failed to parse a data object to JSON.
    case jsonDeserializationFailed(jsonSerializationError: Error, data: Data)

    /// Error for the case that the JSON format was invalid.
    case jsonFormatInvalid(invalidObject: AnyObject)

}

/// JSON helper.
public final class JSONHelper {

    /// Gets the JSON from the given file name.
    ///
    /// - Parameters:
    ///   - jsonFileName: The file name to use.
    ///   - bundle: The bundle to use.
    /// - Returns: The JSON.
    /// - Throws: A JSONError error.
    public static func getJSON(_ jsonFileName: String, bundle: Bundle) throws -> JSON {
        guard let data = loadJSONFile(jsonFileName, bundle: bundle) else {
            throw JSONError.jsonFileNotFound(filePath: "\(jsonFileName).json")
        }

        return try deserializeJSON(data)
    }

    /// Loads the JSON file given the file name.
    ///
    /// - Parameters:
    ///   - name: The file name.
    ///   - bundle: The bundle to use.
    /// - Returns: The file data.
    public static func loadJSONFile(_ name: String, bundle: Bundle) -> Data? {
        guard let jsonFileURL = bundle.path(forResource: name, ofType: "json") else {
            return nil
        }
        do {
            let content = try String(contentsOfFile: jsonFileURL)
            return content.data(using: String.Encoding.utf8)
        } catch {
            return nil
        }
    }

    fileprivate static func deserializeJSON(_ data: Data) throws -> JSON {
        do {
            let object =
                try JSONSerialization
                    .jsonObject(with: data,
                                options: JSONSerialization.ReadingOptions.mutableContainers)

            guard let result = object as? [String: AnyObject] else {
                throw JSONError.jsonFormatInvalid(invalidObject: object as AnyObject)
            }

            return result
        } catch {
            throw JSONError.jsonDeserializationFailed(jsonSerializationError: error, data: data)
        }
    }

    fileprivate static func deserializeJSONArray(_ data: Data) throws -> [JSON] {
        do {
            let object =
                try JSONSerialization
                    .jsonObject(with: data,
                                options: JSONSerialization.ReadingOptions.mutableContainers)

            guard let result = object as? [[String: AnyObject]] else {
                throw JSONError.jsonFormatInvalid(invalidObject: object as AnyObject)
            }

            return result
        } catch {
            throw JSONError.jsonDeserializationFailed(jsonSerializationError: error, data: data)
        }
    }

}
