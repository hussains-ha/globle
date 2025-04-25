//
//  GlobeViewModel.swift
//  Globle
//
//  Created by Hussain Hassan on 4/20/25.
//

import Foundation
import Observation
import SceneKit
import SwiftEarcut
import SwiftUI

@Observable
class GlobeViewModel {
    var geoJSON: GeoJSON?
    var countries: [Feature] = []
    var countryNodes: [SCNNode] = []
    let globeRadius: Double = 1.02
    var countryNodesByName: [String: [SCNNode]] = [:]
    var revealedCountries: [String] = []
    var globeNode: SCNNode?
    var closestCountry: String = ""
    var closestDistance: Double = 50000.0

    let targetCountryName = "France"

    init() {
        loadGeoJSON()
    }

    private func loadGeoJSON() {
        do {
            guard let url = Bundle.main.url(forResource: "countries", withExtension: "geojson") else {
                return
            }
            let data = try Data(contentsOf: url)
            let geo = try JSONDecoder().decode(GeoJSON.self, from: data)

            geoJSON = geo
            countries = geo.features

            buildCountryNodes()
        } catch {
            print("Error loading geoJSON file: \(error)")
        }
    }

    private func buildCountryNodes() {
        guard let target = countries.first(where: {
            if case let .string(name) = $0.properties["ADMIN"] {
                return name == targetCountryName
            }
            return false
        }) else { return }

        guard
            case let .number(targetLat) = target.properties["LABEL_Y"],
            case let .number(targetLon) = target.properties["LABEL_X"]
        else { return }

        for feature in countries {
            guard
                case let .string(name) = feature.properties["ADMIN"],
                case let .number(lat) = feature.properties["LABEL_Y"],
                case let .number(lon) = feature.properties["LABEL_X"]
            else { continue }

            for polygon in feature.geometry.polygons {
                let (_, indices, verts) = processPolygon(polygon)

                let node = createMeshNode(
                    vertices: verts,
                    indices: indices,
                    countryLat: lat,
                    countryLon: lon,
                    targetLat: targetLat,
                    targetLon: targetLon,
                    countryName: name
                )

                node.name = name
                node.eulerAngles.y = -.pi / 2

                countryNodes.append(node)
                countryNodesByName[name, default: []].append(node)
            }
        }
    }

    func processPolygon(_ polygon: [[Double]]) -> (flattened: [Double], indices: [Int32], vertices3D: [SCNVector3]) {
        let rings = [polygon]
        let flattened = SwiftEarcut.Earcut.flatten(data: rings)

        let vertices = flattened.vertices
        let holes = flattened.holes
        let dim = flattened.dim

        let indices = SwiftEarcut.Earcut.tessellate(data: vertices, holeIndices: holes, dim: dim)

        var vertices3D: [SCNVector3] = []

        for i in stride(from: 0, to: vertices.count, by: 2) {
            let lon = vertices[i]
            let lat = vertices[i + 1]
            let vertex = latLonToXYZ(lat: lat, lon: lon, radius: globeRadius)
            vertices3D.append(vertex)
        }

        return (vertices, indices.map { Int32($0) }, vertices3D)
    }

    private func createMeshNode(
        vertices: [SCNVector3],
        indices: [Int32],
        countryLat: Double,
        countryLon: Double,
        targetLat: Double,
        targetLon: Double,
        countryName: String
    ) -> SCNNode {
        let vertexSource = SCNGeometrySource(vertices: vertices)

        let indexData = Data(bytes: indices, count: indices.count * MemoryLayout<Int32>.size)
        let element = SCNGeometryElement(
            data: indexData,
            primitiveType: .triangles,
            primitiveCount: indices.count / 3,
            bytesPerIndex: MemoryLayout<Int32>.size
        )

        let geometry = SCNGeometry(sources: [vertexSource], elements: [element])
        geometry.firstMaterial?.isDoubleSided = true
//        geometry.firstMaterial?.transparency = 0.0

        if countryName == targetCountryName {
            geometry.firstMaterial?.diffuse.contents = UIColor.green
        } else {
            let distance = haversine(lat1: countryLat, lon1: countryLon, lat2: targetLat, lon2: targetLon)
            let closeness = max(0, 1.0 - min(distance / 15000.0, 1.0))
            geometry.firstMaterial?.diffuse.contents = UIColor(red: 1.0, green: 1.0 - closeness, blue: 1.0 - closeness, alpha: 1.0)
        }

        return SCNNode(geometry: geometry)
    }

    func latLonToXYZ(lat: Double, lon: Double, radius: Double) -> SCNVector3 {
        let latRad = lat * Double.pi / 180
        let lonRad = -lon * Double.pi / 180

        let x = radius * cos(latRad) * cos(lonRad)
        let y = radius * sin(latRad)
        let z = radius * cos(latRad) * sin(lonRad)

        return SCNVector3(x, y, z)
    }

    func createCountryNode(points: [SCNVector3]) -> SCNNode {
        let path = UIBezierPath()
        guard let first = points.first else { return SCNNode() }
        path.move(to: CGPoint(x: CGFloat(first.x), y: CGFloat(first.y)))

        for point in points.dropFirst() {
            path.addLine(to: CGPoint(x: CGFloat(point.x), y: CGFloat(point.y)))
        }

        let shape = SCNShape(path: path, extrusionDepth: 0.01)
        shape.firstMaterial?.diffuse.contents = UIColor.white

        let node = SCNNode(geometry: shape)
        node.position = SCNVector3(0, 0, 0)

        return node
    }

    func haversine(lat1: Double, lon1: Double, lat2: Double, lon2: Double) -> Double {
        let R = 6371.0
        let dLat = (lat2 - lat1) * .pi / 180
        let dLon = (lon2 - lon1) * .pi / 180

        let a = sin(dLat / 2) * sin(dLat / 2) +
            cos(lat1 * .pi / 180) * cos(lat2 * .pi / 180) *
            sin(dLon / 2) * sin(dLon / 2)
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))
        return R * c
    }

    func revealCountry(name: String) -> Bool {
        guard let nodes = countryNodesByName[name] else {
            return false
        }

        if revealedCountries.contains(name) {
            return false
        }

        revealedCountries.append(name)

        if let guessed = countries.first(where: {
            if case let .string(n) = $0.properties["ADMIN"] {
                return n == name
            }
            return false
        }),
            let target = countries.first(where: {
                if case let .string(n) = $0.properties["ADMIN"] {
                    return n == targetCountryName
                }
                return false
            }),
            case let .number(guessLat) = guessed.properties["LABEL_Y"],
            case let .number(guessLon) = guessed.properties["LABEL_X"],
            case let .number(targetLat) = target.properties["LABEL_Y"],
            case let .number(targetLon) = target.properties["LABEL_X"]
        {
            let distance = haversine(lat1: guessLat, lon1: guessLon, lat2: targetLat, lon2: targetLon)

            if distance < closestDistance {
                closestDistance = distance
                closestCountry = name
            }
        }

        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.5
        for node in nodes {
            node.geometry?.firstMaterial?.transparency = 1.0
        }
        SCNTransaction.commit()

        return true
    }
}
