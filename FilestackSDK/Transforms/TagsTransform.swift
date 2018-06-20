//
//  TagsTransform.swift
//  FilestackSDK
//
//  Created by Mihály Papp on 20/06/2018.
//  Copyright © 2018 Filestack. All rights reserved.
//

import Foundation

/**
 Returns JSON with tag generated after analysis of image.
 Example: { "tags": { "auto": { "cat": 98,
                                "cat like mammal":77,
                                "close up":78,
                                "european shorthair":68,
                                "fauna":84,
                                "mammal":93,
                                "small to medium sized cats":76,
                                "tabby cat":72,
                                "vertebrate":92,
                                "whiskers":92 }}}
 */
@objc(FSTagsTransform) public class TagsTransform: Transform {
  
  /**
   Initializes a `TagsTransform` object.
   */
  public init() {
    super.init(name: "tags")
  }
}
