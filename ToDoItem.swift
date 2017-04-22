//
//  ToDoItem.swift
//  TodoList
//
//  Created by Chhaya on 21/04/17.
//  Copyright © 2017 Chhaya. All rights reserved.
//

import Foundation
import Realm

class ToDoItem: RLMObject {
    
    dynamic var detail = ""
    dynamic var createdAt = NSDate()
    dynamic var status = 0

}
