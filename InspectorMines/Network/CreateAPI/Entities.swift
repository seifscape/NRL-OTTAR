// Generated by Create API
// https://github.com/kean/CreateAPI
//
// swiftlint:disable all

import Foundation

public struct CreateImages: Codable {
    public var images: [Image]?

    public init(images: [Image]? = nil) {
        self.images = images
    }
}

public struct Capture: Codable {
    public var albumID: Int?
    public var annotation: String
    public var images: [Image]?
    public var dateUpdated: String
    public var coordinates: String
    public var dateCreated: String

    public init(albumID: Int? = nil, annotation: String, images: [Image]? = nil, dateUpdated: String, coordinates: String, dateCreated: String) {
        self.albumID = albumID
        self.annotation = annotation
        self.images = images
        self.dateUpdated = dateUpdated
        self.coordinates = coordinates
        self.dateCreated = dateCreated
    }

    private enum CodingKeys: String, CodingKey {
        case albumID = "album_id"
        case annotation
        case images
        case dateUpdated = "date_updated"
        case coordinates
        case dateCreated = "date_created"
    }
}

public struct Captures: Codable {
    public var captures: [Capture]

    public init(captures: [Capture]) {
        self.captures = captures
    }
}

public struct ValidationError: Codable {
    /// Location
    public var loc: [LocItem]
    /// Message
    public var msg: String
    /// Error Type
    public var type: String

    public struct LocItem: Codable {
        public var string: String?
        public var int: Int?

        public init(string: String? = nil, int: Int? = nil) {
            self.string = string
            self.int = int
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            self.string = try? container.decode(String.self)
            self.int = try? container.decode(Int.self)
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            if let value = string { try container.encode(value) }
            if let value = int { try container.encode(value) }
        }
    }

    public init(loc: [LocItem], msg: String, type: String) {
        self.loc = loc
        self.msg = msg
        self.type = type
    }
}

public struct HTTPValidationError: Codable {
    public var detail: [ValidationError]?

    public init(detail: [ValidationError]? = nil) {
        self.detail = detail
    }
}

public struct DeleteImages: Codable {
    public var imageIDs: [Int]

    public init(imageIDs: [Int]) {
        self.imageIDs = imageIDs
    }

    private enum CodingKeys: String, CodingKey {
        case imageIDs = "image_ids"
    }
}

public struct Image: Codable {
    public var dateCreated: Date
    public var encoded: String
    public var imageID: Int?

    public init(dateCreated: Date, encoded: String, imageID: Int? = nil) {
        self.dateCreated = dateCreated
        self.encoded = encoded
        self.imageID = imageID
    }

    private enum CodingKeys: String, CodingKey {
        case dateCreated = "date_created"
        case encoded
        case imageID = "image_id"
    }
}

public enum AnyJSON: Equatable, Codable {
    case string(String)
    case number(Double)
    case object([String: AnyJSON])
    case array([AnyJSON])
    case bool(Bool)

    var value: Any {
        switch self {
        case .string(let string): return string
        case .number(let double): return double
        case .object(let dictionary): return dictionary
        case .array(let array): return array
        case .bool(let bool): return bool
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case let .array(array): try container.encode(array)
        case let .object(object): try container.encode(object)
        case let .string(string): try container.encode(string)
        case let .number(number): try container.encode(number)
        case let .bool(bool): try container.encode(bool)
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let object = try? container.decode([String: AnyJSON].self) {
            self = .object(object)
        } else if let array = try? container.decode([AnyJSON].self) {
            self = .array(array)
        } else if let string = try? container.decode(String.self) {
            self = .string(string)
        } else if let bool = try? container.decode(Bool.self) {
            self = .bool(bool)
        } else if let number = try? container.decode(Double.self) {
            self = .number(number)
        } else {
            throw DecodingError.dataCorrupted(
                .init(codingPath: decoder.codingPath, debugDescription: "Invalid JSON value.")
            )
        }
    }
}

struct StringCodingKey: CodingKey, ExpressibleByStringLiteral {
    private let string: String
    private var int: Int?

    var stringValue: String { return string }

    init(string: String) {
        self.string = string
    }

    init?(stringValue: String) {
        self.string = stringValue
    }

    var intValue: Int? { return int }

    init?(intValue: Int) {
        self.string = String(describing: intValue)
        self.int = intValue
    }

    init(stringLiteral value: String) {
        self.string = value
    }
}
