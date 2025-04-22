//
//  Model.swift
//  Globle
//
//  Created by Hussain Hassan on 4/20/25.
//

import Foundation

struct GeoJSON: Decodable {
    let features: [Feature]
}

struct Feature: Decodable {
    let properties: [String: JSONValue]
    let geometry: Geometry
}

enum JSONValue: Decodable {
    case string(String)
    case number(Double)
    case bool(Bool)
    case null

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let str = try? container.decode(String.self) {
            self = .string(str)
        } else if let num = try? container.decode(Double.self) {
            self = .number(num)
        } else if let bool = try? container.decode(Bool.self) {
            self = .bool(bool)
        } else {
            self = .null
        }
    }
}

enum Geometry: Decodable {
    case polygon([[[Double]]])
    case multiPolygon([[[[Double]]]])

    var polygons: [[[Double]]] {
        switch self {
        case .polygon(let coords):
            return coords
        case .multiPolygon(let coords):
            return coords.flatMap { $0 }
        }
    }

    enum CodingKeys: String, CodingKey {
        case type
        case coordinates
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)

        switch type {
        case "Polygon":
            let coords = try container.decode([[[Double]]].self, forKey: .coordinates)
            self = .polygon(coords)
        case "MultiPolygon":
            let coords = try container.decode([[[[Double]]]].self, forKey: .coordinates)
            self = .multiPolygon(coords)
        default:
            throw DecodingError.dataCorruptedError(
                forKey: .type,
                in: container,
                debugDescription: "Unsupported geometry type: \(type)"
            )
        }
    }
}
