// Generated by Create API
// https://github.com/kean/CreateAPI
//
// swiftlint:disable all

import Foundation
import Get

extension Paths.Captures {
    public func captureID(_ captureID: Int) -> WithCaptureID {
        WithCaptureID(path: "\(path)/\(captureID)")
    }

    public struct WithCaptureID {
        /// Path: `/captures/{capture_id}`
        public let path: String

        /// Get Capture By Id
        public var get: Request<OTTAR.Capture> {
            .get(path)
        }

        /// Update Capture By Id
        public func patch(_ body: OTTAR.CreateAndUpdateCapture) -> Request<OTTAR.Capture> {
            .patch(path, body: body)
        }

        /// Delete Capture By Id
        public var delete: Request<AnyJSON> {
            .delete(path)
        }
    }
}

extension Paths {
    public static var capture: Capture {
        Capture(path: "/capture")
    }

    public struct Capture {
        /// Path: `/capture`
        public let path: String

        /// Create Capture
        public func post(_ body: OTTAR.CreateAndUpdateCapture) -> Request<OTTAR.Capture> {
            .post(path, body: body)
        }
    }
}

extension Paths.Captures.WithCaptureID {
    public var removeImages: RemoveImages {
        RemoveImages(path: path + "/remove_images")
    }

    public struct RemoveImages {
        /// Path: `/captures/{capture_id}/remove_images`
        public let path: String

        /// Delete Images From Album
        public func delete(_ body: OTTAR.DeleteImages) -> Request<AnyJSON> {
            .delete(path, body: body)
        }
    }
}

extension Paths {
    public static var image: Image {
        Image(path: "/image")
    }

    public struct Image {
        /// Path: `/image`
        public let path: String

        /// Add Image
        public func post(_ body: OTTAR.CreateImage) -> Request<OTTAR.Image> {
            .post(path, body: body)
        }
    }
}

extension Paths.Captures.WithCaptureID {
    public var addImages: AddImages {
        AddImages(path: path + "/add_images")
    }

    public struct AddImages {
        /// Path: `/captures/{capture_id}/add_images`
        public let path: String

        /// Add Images To Album
        public func post(_ body: OTTAR.CreateImages) -> Request<OTTAR.Images> {
            .post(path, body: body)
        }
    }
}

extension Paths {
    public static var captures: Captures {
        Captures(path: "/captures")
    }

    public struct Captures {
        /// Path: `/captures`
        public let path: String

        /// Get All Captures
        public var get: Request<OTTAR.Captures> {
            .get(path)
        }
    }
}

extension Paths.Captures.WithCaptureID {
    public var addImage: AddImage {
        AddImage(path: path + "/add_image")
    }

    public struct AddImage {
        /// Path: `/captures/{capture_id}/add_image`
        public let path: String

        /// Add Image To Album
        public func post(_ body: OTTAR.Image) -> Request<OTTAR.CreateImage> {
            .post(path, body: body)
        }
    }
}

extension Paths {
    public static var images: Images {
        Images(path: "/images")
    }

    public struct Images {
        /// Path: `/images`
        public let path: String
    }
}

extension Paths.Images {
    public func imageID(_ imageID: Int) -> WithImageID {
        WithImageID(path: "\(path)/\(imageID)")
    }

    public struct WithImageID {
        /// Path: `/images/{image_id}`
        public let path: String

        /// Delete Image By Id
        public var delete: Request<AnyJSON> {
            .delete(path)
        }
    }
}

public enum Paths {}
