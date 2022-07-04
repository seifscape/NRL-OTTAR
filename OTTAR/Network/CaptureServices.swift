//
//  CaptureServices.swift
//  OTTAR
//
//  Created by Seif Kobrosly on 6/13/22.
//  Copyright © 2022 Apptitude Labs LLC. All rights reserved.
//

import Foundation
import Get

struct CaptureServices {

    static func getCapture(capture: Capture) async throws -> Capture {
        let captureTask = Task { () -> Capture in
            try await OTTARNetworkAPI.sharedInstance.client.send(Paths.captures.captureID(capture.captureID).get).value
        }
        return try await captureTask.value
    }

    static func addImages(capture: Capture, images: [CreateImage]) async throws -> Images? {
        let updateTask =  Task { () -> Images? in
            return try await OTTARNetworkAPI.sharedInstance.client.send(Paths.captures.captureID(capture.captureID).addImages.post(CreateImages(images: images))).value
        }
        return try await updateTask.value
    }

    static func deleteImages(capture: Capture, listOfImages: [Int]) async throws {
        Task {
            return try await
            OTTARNetworkAPI.sharedInstance.client.send(Paths.captures.captureID(capture.captureID).removeImages.delete(DeleteImages(imageIDs: listOfImages))).value
        }
    }

    static func deleteCapture(captureId: Int) async throws {

        Task {
            return try await
            OTTARNetworkAPI.sharedInstance.client.send(Paths.captures.captureID(captureId).delete).value
        }
    }

    static func updateCapture(capture: Capture, updatedText: String) async throws -> Capture? {
        let updateTask =  Task { () -> Capture? in
            return try await
            OTTARNetworkAPI.sharedInstance.client.send(Paths.captures.captureID(capture.captureID).patch(CreateAndUpdateCapture(annotation: updatedText))).value
        }
        return try await updateTask.value
    }

    static func createCapture(coordinateString: String, images: [CreateImage]? = nil) async throws -> Capture? {
        let captureTask = Task { () -> Capture? in
            let capture = CreateAndUpdateCapture(annotation: "", dateUpdated: nil, coordinates: coordinateString, images: images, dateCreated: Date.now)
            return try await OTTARNetworkAPI.sharedInstance.client.send(Paths.capture.post(capture)).value
        }
        return try await captureTask.value
    }

    static func getCaptures() async throws -> Captures?
    {
        let capturesTask = Task { () -> Captures? in
            return try await OTTARNetworkAPI.sharedInstance.client.send(Paths.captures.get).value
        }
        return try await capturesTask.value
    }


    func retrying<T>(attempts: Int = 3,
                    delay: TimeInterval = 1,
                     closure: @escaping () async throws -> T) async rethrows -> T {
        for _ in 0 ..< attempts - 1 {
            do {
                return try await closure()
            } catch {
                let delay = UInt64(delay * TimeInterval(1_000_000_000))
                try await Task.sleep(nanoseconds: delay)
            }
        }
        return try await closure()
    }

}

extension Task where Failure == Error {
    @discardableResult
    static func retrying(
        priority: TaskPriority? = nil,
        maxRetryCount: Int = 3,
        retryDelay: TimeInterval = 1,
        operation: @Sendable @escaping () async throws -> Success
    ) -> Task {
        Task(priority: priority) {
            for _ in 0..<maxRetryCount {
                do {
                    return try await operation()
                } catch {
                    let oneSecond = TimeInterval(1_000_000_000)
                    let delay = UInt64(oneSecond * retryDelay)
                    try await Task<Never, Never>.sleep(nanoseconds: delay)

                    continue
                }
            }
            
            try Task<Never, Never>.checkCancellation()
            return try await operation()
        }
    }
}
