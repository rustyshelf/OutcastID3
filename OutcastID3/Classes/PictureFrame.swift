//
//  PictureFrame.swift
//  OutcastID3
//
//  Created by Quentin Zervaas on 24/11/18.
//

import Foundation
import UIKit

public struct PictureFrame: Frame {
    enum CodingKeys: String, CodingKey {
        case mimeType
        case pictureType
        case pictureDescription
        case image
    }
    
    enum Error: Swift.Error {
        case encodingError
        case decodingError
    }

    public enum PictureType: UInt8, Codable {
        case other              = 0x00
        case fileIcon32x32Png   = 0x01
        case fileIconOther      = 0x02
        case coverFront         = 0x03
        case coverBack          = 0x04
        case leafletPage        = 0x05
        case mediaLabel         = 0x06
        case leadArtist         = 0x07
        case artist             = 0x08
        case conductor          = 0x09
        case bandOrchestra      = 0x0a
        case composer           = 0x0b
        case textWriter         = 0x0c
        case recordingLocation  = 0x0d
        case duringRecording    = 0x0e
        case duringPerformance  = 0x0f
        case movieScreenCapture = 0x10
        case brightColoredFish  = 0x11
        case illustration       = 0x12
        case bandLogotype       = 0x13
        case publisherLogotype  = 0x14
        
        public var description: String {
            switch self {
                
            case .other:
                return "Other"
            case .fileIcon32x32Png:
                return "File Icon 32x32 PNG"
            case .fileIconOther:
                return "File Icon Other"
            case .coverFront:
                return "Front Cover"
            case .coverBack:
                return "Back Cover"
            case .leafletPage:
                return "Leaflet Page"
            case .mediaLabel:
                return "Media Label"
            case .leadArtist:
                return "Lead Artist"
            case .artist:
                return "Artist"
            case .conductor:
                return "Conductor"
            case .bandOrchestra:
                return "Band/Orchestra"
            case .composer:
                return "Composer"
            case .textWriter:
                return "Lyricist/Text Writer"
            case .recordingLocation:
                return "Recording Location"
            case .duringRecording:
                return "During Recording"
            case .duringPerformance:
                return "During Performance"
            case .movieScreenCapture:
                return "Movie Screen Capture"
            case .brightColoredFish:
                return "Bright Colored Fish"
            case .illustration:
                return "Illustration"
            case .bandLogotype:
                return "Band Logotype"
            case .publisherLogotype:
                return "Publisher Logotype"
            }
        }
    }
    
    public let mimeType: String
    public let pictureType: PictureType
    public let pictureDescription: String?
    public let picture: UIImage
    
    public var debugDescription: String {
        return "mimeType=\(self.mimeType) pictureType=\(self.pictureType.description) pictureDescription=\(String(describing: self.pictureDescription)) picture=\(self.picture)"
    }

    static func parse(version: MP3File.ID3Tag.Version, data: Data) -> PictureFrame? {
        
        var frameContentRangeStart = version.frameHeaderSizeInBytes
        
        let encoding = String.Encoding.fromEncodingByte(byte: data[frameContentRangeStart], version: version)
        frameContentRangeStart += 1
        
        let mimeType = data.readString(offset: &frameContentRangeStart, encoding: .isoLatin1)
        
        let pictureTypeByte = data[frameContentRangeStart]
        frameContentRangeStart += 1
        
        let pictureType = PictureType(rawValue: pictureTypeByte) ?? .other
        
        let pictureDescription = data.readString(offset: &frameContentRangeStart, encoding: encoding)
        
        let pictureBytes = data.subdata(in: frameContentRangeStart ..< data.count)
        
        guard let picture = UIImage(data: pictureBytes) else {
            return nil
        }
        
        return PictureFrame(
            mimeType: mimeType ?? "",
            pictureType: pictureType,
            pictureDescription: pictureDescription,
            picture: picture
        )
    }
}

extension PictureFrame {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let data = try container.decode(Data.self, forKey: CodingKeys.image)
        guard let image = NSKeyedUnarchiver.unarchiveObject(with: data) as? UIImage else {
            throw Error.decodingError
        }
        
        self.picture = image
        
        self.mimeType = try container.decode(String.self, forKey: .mimeType)
        self.pictureDescription = try container.decode(String.self, forKey: .pictureDescription)
        self.pictureType = try container.decode(PictureType.self, forKey: .pictureType)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        let data = NSKeyedArchiver.archivedData(withRootObject: self.picture)
        try container.encode(data, forKey: .image)
        
        try container.encode(self.mimeType, forKey: .mimeType)
        try container.encode(self.pictureType, forKey: .pictureType)
        try container.encode(self.pictureDescription, forKey: .pictureDescription)
    }
}