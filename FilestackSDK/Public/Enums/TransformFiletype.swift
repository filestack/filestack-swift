//
//  TransformFiletype.swift
//  FilestackSDK
//
//  Created by Mihály Papp on 15/06/2018.
//  Copyright © 2018 Filestack. All rights reserved.
//

import Foundation

/**
 Represents an image transform noise reduction type.
 */
@objc(FSTransformFiletype) public enum TransformFiletype: UInt, CustomStringConvertible {
    /// doc
    case doc

    /// docx
    case docx

    /// HTML
    case html

    /// JPG
    case jpg

    /// opd
    case odp

    /// ods
    case ods

    /// odt
    case odt

    /// pjpg
    case pjpg

    /// pdf
    case pdf

    /// png
    case png

    /// ppt
    case ppt

    /// pptx
    case pptx

    /// svg
    case svg

    /// txt
    case txt

    /// webp
    case webp

    /// xls
    case xls

    /// xlsx
    case xlsx

    // MARK: - CustomStringConvertible

    /// Returns a `String` representation of self.
    public var description: String {
        switch self {
        case .doc: return "doc"
        case .docx: return "docx"
        case .html: return "html"
        case .jpg: return "jpg"
        case .odp: return "odp"
        case .ods: return "ods"
        case .odt: return "odt"
        case .pjpg: return "pjpg"
        case .pdf: return "pdf"
        case .png: return "png"
        case .ppt: return "ppt"
        case .pptx: return "pptx"
        case .svg: return "svg"
        case .txt: return "txt"
        case .webp: return "webp"
        case .xls: return "xls"
        case .xlsx: return "xlsx"
        }
    }
}
