//
//  ShortenString.swift
//  CHOW
//
//  Created by Jo du Plessis on 2016/08/13.
//  Copyright © 2016 CHOW. All rights reserved.
//

import Foundation

func shortenString(text: String, start: Int, end: Int) -> String {
    return text[text.startIndex.advancedBy(start)...text.startIndex.advancedBy(end)]
}