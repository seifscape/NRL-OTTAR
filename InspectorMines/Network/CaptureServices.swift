//
//  CaptureServices.swift
//  InspectorMines
//
//  Created by Seif Kobrosly on 6/13/22.
//  Copyright © 2022 Apptitude Labs LLC. All rights reserved.
//

import Foundation
import Get

struct CaptureServices {

    static func getCapture(capture: Capture) async throws -> Capture {
        let captureTask = Task { () -> Capture in
            try await InspectorMinesNetworkAPI.sharedInstance.client.send(Paths.captures.captureID(capture.captureID).get).value
        }
        return try await captureTask.value
    }

    static func addImages(capture: Capture, images: [CreateImage]) async throws -> CreateImages? {
        let updateTask =  Task { () -> CreateImages? in
            return try await InspectorMinesNetworkAPI.sharedInstance.client.send(Paths.captures.captureID(capture.captureID).addImages.post(CreateImages(images: images))).value
        }
        return try await updateTask.value
    }

    static func deleteImages(capture: Capture, listOfImages: [Int]) async throws {
        Task {
            return try await
            InspectorMinesNetworkAPI.sharedInstance.client.send(Paths.captures.captureID(capture.captureID).removeImages.delete(DeleteImages(imageIDs: listOfImages))).value
        }
    }

    static func deleteCapture(captureId: Int) async throws {

        Task {
            return try await
            InspectorMinesNetworkAPI.sharedInstance.client.send(Paths.captures.captureID(captureId).delete).value
        }
    }

    static func updateCapture(capture: Capture, updatedText: String) async throws -> Capture? {
        let updateTask =  Task { () -> Capture? in
            return try await
            InspectorMinesNetworkAPI.sharedInstance.client.send(Paths.captures.captureID(capture.captureID).patch(CreateAndUpdateCapture(annotation: updatedText))).value
        }
        return try await updateTask.value
    }

    static func createCapture(coordinateString: String, images: [CreateImage]) async throws -> Capture? {
        let captureTask = Task { () -> Capture? in
            let capture = CreateAndUpdateCapture(dateUpdated: nil, images: images, coordinates: coordinateString, dateCreated: Date.now, annotation: "")
            return try await InspectorMinesNetworkAPI.sharedInstance.client.send(Paths.capture.post(capture)).value
        }
        return try await captureTask.value
    }

    static func getCaptures() async throws -> Captures?
    {
        let capturesTask = Task { () -> Captures? in
            return try await InspectorMinesNetworkAPI.sharedInstance.client.send(Paths.captures.get).value
        }
        return try await capturesTask.value
    }
}
